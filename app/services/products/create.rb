module Products
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
              :category,
              :title,
              :description,
              :original_price,
              :price,
              :pictures,
              presence: true, strict: ApiError::FailedValidation

    validate :type_is_products
    validate :valid_pictures
    validate :valid_user

    RESOURCE_TYPE = "products"

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

    attr_accessor :success_result, :type, :attributes, :data, :user_id, :category, :title, :description, :original_price, :price, :pictures

    def initialize(params = {})
      @user_id = params[:user_id]
      @data = params[:data]
      @attributes = data[:attributes] || {}
      @type = data[:type]
      @category = attributes[:category]
      @title = attributes[:title]
      @description = attributes[:description]
      @original_price = attributes[:original_price]
      @price = attributes[:price]
      @pictures = attributes[:pictures]
      attributes[:status] = "published"
      valid?
    end

    def generate_result!
      product = Product.new(attributes.except(:pictures))
      product.product_pictures = product_pictures
      if product.valid? && product.save
        self.success_result = product
      else
        product.errors.each do |k, v|
          self.errors.add(k, v)
        end
        raise ApiError::FailedValidation.new(errors.full_messages.join(', '))
      end
    end

    private

    def type_is_products
      unless type == RESOURCE_TYPE
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_type", type: type, resource_type: RESOURCE_TYPE))
      end
    end

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def product_pictures
      @product_pictures ||= ProductPicture.where(id: pictures)
    end

    def valid_pictures
      if pictures.empty?
        raise ApiError::FailedValidation.new(I18n.t("product.errors.pictures_are_empty"))
      end
    end

    def valid_user
      unless user
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end
  end
end
