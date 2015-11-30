module Products
  class CreateComment

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
              :product_id,
              :data,
              :text,
              presence: true, strict: ApiError::FailedValidation

    validate :valid_type
    validate :valid_user
    validate :valid_product

    RESOURCE_TYPE = "text_comments"

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

    attr_accessor :success_result, :type, :attributes, :data, :user_id, :text, :product_id

    def initialize(params = {})
      @product_id = params[:product_id]
      @user_id = params[:user_id]
      @data = params[:data]
      @attributes = data[:attributes] || {}
      @type = data[:type]
      @text = attributes[:text]
      valid?
    end

    def generate_result!
      comment = product.comments.build(user: user, data: data.to_json, user_pic: user.pic.url(:small))
      comment.save!
      self.success_result = comment
    end

    private

    def valid_type
      unless type == RESOURCE_TYPE
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_type", type: type, resource_type: RESOURCE_TYPE))
      end
    end

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