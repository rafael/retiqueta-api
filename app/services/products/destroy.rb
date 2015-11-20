module Products
  class Destroy

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :id,
              :user_id,
              presence: true, strict: ApiError::FailedValidation

    validate :valid_user
    validate :valid_product
    validate :user_can_delete_product
    validate :status_is_published

    PUBLISHED_STATUS = "published"

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

    attr_accessor :user_id, :id

    def initialize(params = {})
      @user_id = params[:user_id]
      @id = params[:id]
      valid?
    end

    def generate_result!
      product.destroy!
    end

    private

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def product
      @product ||= Product.find_by_uuid(id)
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

    def user_can_delete_product
      unless product.user == user
        raise ApiError::Unauthorized.new(I18n.t("errors.messages.unauthorized"))
      end
    end

    def status_is_published
      unless product.status == PUBLISHED_STATUS
        raise ApiError::FailedValidation.new(I18n.t("product.errors.invalid_type"))
      end
    end
  end
end
