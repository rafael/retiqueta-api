module Products
  class Read

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :product_id,
              presence: true, strict: ApiError::FailedValidation

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

    attr_accessor :success_result, :type, :product_id

    def initialize(params = {})
      @product_id = params[:id]
      valid?
    end

    def generate_result!
      self.success_result = product
    end

    private

    def product
      @product ||= Product.find_by_uuid(product_id)
    end

    def valid_product
      unless product
        raise ApiError::NotFound.new(I18n.t("product.errors.not_found"))
      end
    end
  end
end
