module Orders
  class Create
    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :data,
              :attributes,
              :type,
              :user_id,
              :payment_data,
              :line_items,
              presence: true, strict: ApiError::FailedValidation

    validate :type_is_orders
    validate :valid_user
    validate :valid_product_statuses
    validate :valid_line_items

    RESOURCE_TYPE = 'orders'

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {}, deps = {})
      service = new(params, deps)
      service.generate_result!
      service
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :success_result,
                  :type,
                  :attributes,
                  :data,
                  :user_id,
                  :payment_data,
                  :line_items,
                  :product_ar_interface,
                  :payment_providers

    def initialize(params = {}, deps = {})
      @user_id = params[:user_id]
      @data = params[:data] || {}
      @attributes = data[:attributes] || {}
      @type = data[:type]
      @line_items = attributes[:line_items]
      @payment_data = attributes[:payment_data]
      @product_ar_interface = deps.fetch(:product_ar_interface) { Product }
      @payment_providers = deps.fetch(:payment_providers) { PaymentProviders }
      valid?
    end

    def generate_result!
      order = create_order
      self.success_result = order
    end

    private

    def type_is_orders
      return if type == RESOURCE_TYPE
      fail(ApiError::FailedValidation,
           I18n.t('errors.invalid_type',
                  type: type, resource_type: RESOURCE_TYPE))
    end

    def create_order
      products, charge = fetch_products_and_charge_credit_card
      order_amount = order_amount(products)
      order = create_order!(charge, order_amount)
      create_line_items!(order)
      sales = create_sale!(order, order_amount, products)
      create_fulfillment!(order)
      UserMailer.order_created(order).deliver_later
      send_sales_notfications(sales)
      order
    end

    def send_sales_notfications(sales)
      send_push_to_sellers(sales)
      send_email_to_sellers(sales)
    end

    def send_email_to_sellers(sales)
      sales.each do |sale|
        UserMailer.product_sale(sale).deliver_later
      end
    end

    def send_push_to_sellers(sales)
      sales.each do |sale|
        url = Rails
              .application
              .routes
              .url_helpers.v1_sale_url(sale.uuid, host: 'https://api.retiqueta.com')
        payload = {
          type: 'url',
          url:  url
        }
        SendPushNotification.perform_later([sale.user],
                                           'Retiqueta',
                                           I18n.t('orders.seller_notification'),
                                           payload)
      end
    end

    def create_order!(charge, order_amount)
      Order.create!(user_id: user.uuid,
                    payment_transaction_id: charge.uuid,
                    total_amount: order_amount,
                    financial_status: Order::PAID_STATUS,
                    currency: 'VEF')
    end

    def create_line_items!(order)
      line_items.each do |line_item|
        LineItem.create!(product_type: line_item[:product_type].classify,
                         product_id: line_item[:product_id],
                         order_id: order.uuid)
      end
    end

    def create_fulfillment!(order)
      Fulfillment.create!(order_id: order.uuid,
                          status: Fulfillment::PENDING_STATUS)
    end

    def create_sale!(order, order_amount, products)
      products.map do |product|
        Sale.create!(user_id: product.user.uuid,
                     order_id: order.uuid,
                     store_fee: order_amount * product.user.store_fee,
                     amount: order_amount * (1 - product.user.store_fee))
      end
    end

    def fetch_products_and_charge_credit_card
      products = nil
      charge = nil
      product_ar_interface.transaction do
        products = fetch_products.lock(true)
        fail ActiveRecord::Rollback unless valid_product_statuses?(products)
        # Mark all products as sold
        charge = charge_credit_card!(products)
        products.each do |p|
          p.status = Product::SOLD_STATUS
          p.save!
        end
      end
      [products, charge]
    rescue ActiveRecord::Rollback => e
      Rails.logger.fatal("Fail to update products while charging credit card: #{e.message}")
      raise ApiError::InternalServer, I18n.t('orders.errors.something_went_wrong')
    end

    def charge_credit_card!(products)
      order_amount = order_amount(products)
      prepared_payment_data = {
        transaction_amount: order_amount,
        description:  I18n.t('orders.ml_description'),
        installments:  1,
        payer:  {
          email:  user.email
        }
      }.merge(payment_data)

      payment_transaction_id = SecureRandom.uuid

      create_audit(payment_transaction_id,
                   'attempting_to_charge_card',
                   { paylod_to_payment_provider: prepared_payment_data,
                     payment_provider: PaymentProviders::ML_VE_NAME,
                     line_items: line_items }.to_json)
      payment_response = payment_providers.mp_ve.post('/v1/payments',
                                                      prepared_payment_data)

      # Mercado libre returns 201 for failed payments and then has the error
      # in the status key in the response :/
      if payment_response['status'] != '201' ||
         payment_response['response']['status'] != 'approved'
        create_audit(payment_transaction_id,
                     'fail_to_collect_payment_from_credit_card',
                     payment_provider_response: payment_response)

        # TODO: Parse error codes to give better error feedback to users
        fail(ApiError::FailedValidation,
             I18n.t('orders.errors.fail_to_charge_credit_card'))
      end
      create_audit(payment_transaction_id,
                   'credit_card_succesfully_charged',
                   payment_provider_response: payment_response.to_json)
      PaymentTransaction.create!(uuid: payment_transaction_id,
                                 user_id: user.uuid,
                                 status: PaymentTransaction::PROCESSED_STATE,
                                 payment_provider: PaymentProviders::ML_VE_NAME,
                                 payment_method: payment_data[:payment_method_id],
                                 metadata: payment_response.to_json)
    end

    def create_audit(payment_transaction_id, action, metadata)
      PaymentAuditTrail.create!(user_id: user.uuid,
                                payment_transaction_id: payment_transaction_id,
                                action: action,
                                metadata: metadata)
    end

    def product_types
      @product_types ||=
        line_items.map { |line_item|  line_item[:product_type] }
    end

    def fetch_products
      product_ar_interface.where(uuid: product_ids)
    end

    def order_amount(products)
      products.reduce(0) { |acc, product| acc += product.price; acc }
    end

    def product_ids
      @product_ids ||=
        line_items.map { |line_item|  line_item[:product_id] }
    end

    def product_statuses(products)
      products.map(&:status)
    end

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    # Validations

    def valid_product_statuses
      return if valid_product_statuses?(fetch_products)
      fail(ApiError::FailedValidation, 'Trying to buy products that are already sold')
    end

    def valid_product_statuses?(products)
      product_statuses(products).all? { |status| status == Product::PUBLISHED_STATUS }
    end

    def valid_line_items
      # Use what json api uses to set the type of a resource:
      # https://github.com/rails-api/active_model_serializers/blob/6b4c8df6fb6bc142ee6a74da51bb26c42a025b3c/lib/active_model_serializers/adapter/json_api/resource_identifier.rb#L26
      valid_types =
        product_types.all? { |product_type| product_type == Product.model_name.plural }

      products = fetch_products

      unless valid_types
        fail(ApiError::FailedValidation, 'Invalid product type in line items')
      end

      if products.size != line_items.size
        missing_ids = line_items.map { |l| l[:product_id] } - products.map(&:uuid)
        fail(ApiError::FailedValidation,
             "Couldn't find the following line items: #{missing_ids.join(',')}")
      end
    end

    def valid_user
      return if user
      fail(ApiError::NotFound, I18n.t('user.errors.not_found'))
    end
  end
end
