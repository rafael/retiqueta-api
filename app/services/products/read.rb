module Products
  class Read

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :user_id,
              :product_id,
              presence: true, strict: ApiError::FailedValidation

    validate :valid_user
    validate :valid_product

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {})
      service = self.new(params)
      service.generate_result!
      service
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :success_result, :type, :user_id, :product_id

    def initialize(params = {})
      @product_id = params[:id]
      @user_id = params[:user_id]
      valid?
    end

    def generate_result!
      self.success_result = product
    end

    private

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def product
      @product ||= Product.find_by_uuid(product_id)
    end

    def valid_product
      unless product
        raise ApiError::NotFound.new(I18n.t("product.errors.not_found"))
      end
    end

    def valid_user
      unless user
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end
  end
end
