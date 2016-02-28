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
              :credit_card_token,
              :shipping_address,
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

    def self.call(params = {})
      service = new(params)
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
                  :credit_card_token,
                  :shipping_address,
                  :line_items

    def initialize(params = {})
      @user_id = params[:user_id]
      @data = params[:data] || {}
      @attributes = data[:attributes] || {}
      @type = data[:type]
      @line_items = attributes[:line_items]
      @credit_card_token = attributes[:credit_card_token]
      @shipping_address = attributes[:shipping_address]
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
      ActiveRecord::Base.transaction do
        products = fetch_products
        fail ActiveRecord::Rollback unless valid_product_statuses?(products)
        # Mark all products as sold
        products.update_all(status: Product::SOLD_STATUS)

        charge = charge_credit_card!

        order_amount = order_amount(products)
        order = create_order!(charge, order_amount)
        create_line_items!(order)
        create_sale!(order, order_amount, products)
        create_fulfillment!(order)
        order
      end
    end

    def create_order!(charge, order_amount)
      Order.create!(shipping_address: shipping_address,
                    user_id: user.uuid,
                    payment_transaction_id: 'test',
                    total_amount: order_amount,
                    financial_status: Order::PAID_STATUS,
                    currency: 'VEF')

    end

    def create_line_items!(order)
      line_items.each do |line_item|
        LineItem.create!(product_type: line_item[:product_type],
                         product_id: line_item[:product_id],
                         order_id: order.uuid)
      end
    end

    def create_fulfillment!(order)
      Fulfillment.create!(order_id: order.uuid,
                          status: Fulfillment::PENDING_STATUS)
    end

    def create_sale!(order, order_amount, products)
      products.each do |product|
        Sale.create!(user_id: product.user.uuid,
                     order_id: order.uuid,
                     store_fee: order_amount * (1 - 0.8), # TODO Replace with user fee
                     amount: order_amount * 0.8) # TODO Replace with user fee

      end
    end

    def charge_credit_card!
    end

    def product_types
      @product_types ||=
        line_items.map { |line_item|  line_item[:product_type] }
    end

    def fetch_products
      Product.where(uuid: product_ids)
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
      valid_types =
        product_types.all? { |product_type| product_type == 'product' }

      unless valid_types
        fail(ApiError::FailedValidation, 'Invalid product type in line items')
      end

      if line_items.empty? || fetch_products.size != line_items.size
        fail(ApiError::FailedValidation, 'Line items are empty')
      end
    end

    def valid_user
      return if user
      fail(ApiError::NotFound, I18n.t('user.errors.not_found'))
    end
  end
end
