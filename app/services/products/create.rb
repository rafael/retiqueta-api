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
              :description,
              :original_price,
              :price,
              :pictures,
              presence: true, strict: ApiError::FailedValidation

    validate :type_is_products
    validate :valid_pictures
    validate :valid_user

    RESOURCE_TYPE = 'products'

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

    attr_accessor :success_result, :type, :attributes, :data, :user_id,
                  :category, :title, :description, :original_price,
                  :price, :pictures

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
      attributes[:status] = 'published'
      valid?
    end

    def generate_result!
      product = Product.new(attributes.except(:pictures).merge(user_id: user_id))
      product.product_pictures = product_pictures
      if product.valid?
        ActiveRecord::Base.transaction do
          product_pictures.each do |product_picture|
            product_picture.position = product_picture_positions[product_picture.id]
            product_picture.save!
          end
          product.save!
        end
        Librato.increment 'product.create.success'
        self.success_result = product
      else
        Librato.increment 'product.create.failure'
        product.errors.each do |k, v|
          errors.add(k, v)
        end
        fail ApiError::FailedValidation.new(errors.full_messages.join(', '))
      end
    end

    private

    def type_is_products
      unless type == RESOURCE_TYPE
        fail ApiError::FailedValidation.new(I18n.t('errors.invalid_type', type: type, resource_type: RESOURCE_TYPE))
      end
    end

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def product_pictures
      @product_pictures ||= ProductPicture.where(id: pictures)
    end

    def product_picture_positions
      @product_picture_positions ||= pictures.each_with_index.inject({}) { |acc, (id, index)| acc[id.to_i] = index; acc }
    end

    def valid_pictures
      if product_pictures.empty? || product_pictures.size != pictures.size
        fail ApiError::FailedValidation.new(I18n.t('product.errors.pictures_are_empty'))
      end
      unless product_pictures.map(&:product_id).compact.empty?
        fail ApiError::FailedValidation.new(
               I18n.t('product.errors.pictures_are_used_in_other_product'))
      end
    end

    def valid_user
      fail ApiError::NotFound.new(I18n.t('user.errors.not_found')) unless user
    end
  end
end
