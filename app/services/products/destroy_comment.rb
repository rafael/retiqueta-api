module Products
  class DestroyComment

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :user_id,
              :product_id,
              :comment_id,
              presence: true, strict: ApiError::FailedValidation

    validate :valid_user
    validate :valid_product
    validate :valid_comment

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

    attr_accessor :user_id, :product_id, :comment_id

    def initialize(params = {})
      @product_id = params[:product_id]
      @comment_id = params[:id]
      @user_id = params[:user_id]
      valid?
    end

    def generate_result!
      unless comment.user == user
        raise ApiError::Unauthorized.new(I18n.t("errors.messages.unauthorized"))
      end
      comment.destroy!
    end

    private

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def product
      @product ||= Product.find_by_uuid(product_id)
    end

    def comment
      @comment ||= product.comments.where(uuid: comment_id).first
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

    def valid_comment
      unless comment
        raise ApiError::NotFound.new(I18n.t("comment.errors.not_found"))
      end
    end
  end
end
