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

    attr_accessor :success_result, :query, :per_page, :page

    def initialize(params = {})
      @query = params[:q]
      page = params.fetch(:page) { {} }
      @per_page = page[:size] || 25
      @page = page[:number] || 1
    end

    def generate_result!
      products = Product.search(query: query, per_page: per_page, page: page).to_a
      self.success_result = products
    end
  end
end
