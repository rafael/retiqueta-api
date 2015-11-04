module Products
  class Search

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

    attr_accessor :success_result, :query

    def initialize(params = {})
      Rails.logger.fatal params
      @query = params[:q]
    end

    def generate_result!
      products_search_result = Product.search(query: query)
      products = products_search_result.map do |result|
        # Let's fake an AR product.
        Product.new(uuid: result.uuid,
                    title: result.title,
                    category: result.category,
                    description: result.description,
                    status: result.status)
      end
      self.success_result = products
    end
  end
end
