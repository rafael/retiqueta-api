module Products
  class Like

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validate :valid_user
    validate :valid_product

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {})
      service = self.new(params)
      service.generate_result! if service.valid?
      service
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :user_id, :product_id

    def initialize(params = {})
      @user_id = params[:user_id]
      @product_id = params[:product_id]
      valid?
    end

    def generate_result!
      result = product.liked_by(user)
      send_push_notification
      result
    end

    def send_push_notification
      url = Rails
            .application
            .routes
            .url_helpers.v1_product_url(product.uuid, host: 'https://api.retiqueta.com')
      payload = {
        type: 'url',
        url:  url
      }

      SendPushNotification.perform_later(product.user,
                                         'Retiqueta',
                                         I18n.t('product.like_push', username: user.username),
                                         payload)
    end

    private

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def product
      @product ||= Product.find_by_uuid(product_id)
    end

    def valid_user
      unless user
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end

    def valid_product
      unless product
        raise ApiError::NotFound.new(I18n.t("product.errors.not_found"))
      end
    end
  end
end
