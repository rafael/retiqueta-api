module Products
  class CommentsIndex

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

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

    attr_accessor :success_result, :product_id

    def initialize(params = {})
      @product_id = params.fetch(:product_id)
    end

    def generate_result!
      comments = product.comments
      self.success_result = comments
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
