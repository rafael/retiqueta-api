module Products
  class Update

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
              presence: true, strict: ApiError::FailedValidation

    validate :type_is_products
    validate :valid_pictures
    validate :valid_user
    validate :valid_product

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

    attr_accessor :success_result,
      :type,
      :attributes,
      :data,
      :user_id,
      :product_id,
      :pictures

    def initialize(params = {})
      @product_id = params[:id]
      @user_id = params[:user_id]
      @data = params[:data]
      @attributes = data[:attributes] || {}
      @type = data[:type]
      @pictures = attributes[:pictures] || []
      valid?
    end

    def generate_result!
      product.attributes = attributes.except(:pictures)

      if product.valid?
        update_product!
        self.success_result = product
      else
        product.errors.each do |k, v|
          self.errors.add(k, v)
        end
        raise ApiError::FailedValidation.new(errors.full_messages.join(', '))
      end
    end

    private

    def update_product!
      if pictures.empty?
        product.save!
      else
        product.product_pictures = product_pictures
        ActiveRecord::Base.transaction do
          product_pictures.each do |product_picture|
            product_picture.position = product_picture_positions[product_picture.id]
            product_picture.save!
          end
          product.save!
        end
      end
    end

    def type_is_products
      unless type == RESOURCE_TYPE
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_type", type: type, resource_type: RESOURCE_TYPE))
      end
    end

    def user
      @user ||= User.find_by(uuid: user_id)
    end

    def product
      @product ||= Product.find_by(uuid: product_id)
    end

    def product_pictures
      @product_pictures ||= ProductPicture.where(id: pictures)
    end

    def product_picture_positions
      @product_picture_positions ||= pictures.each_with_index.inject({}) { |acc, (id, index)| acc[id] = index; acc }
    end

    def valid_pictures
      if !pictures.empty? && product_pictures.size != pictures.size
        raise ApiError::FailedValidation.new(I18n.t("product.errors.invalid_pictures"))
      end
    end

    def valid_user
      unless user
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end

    def valid_product
      if product.nil? || user.uuid != product.user_id
        raise ApiError::NotFound.new(I18n.t("product.errors.not_found"))
      end
    end
  end
end
