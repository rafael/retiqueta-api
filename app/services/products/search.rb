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

    attr_accessor :success_result, :query, :per_page, :page, :user_id

    def initialize(params = {})
      @query = params[:q]
      page = params.fetch(:page) { {} }
      @per_page = page[:size] || 25
      @page = page[:number] || 1
      @user_id = params[:user_id]
    end

    def generate_result!
      products = Product.search(query: query).page(page).per(per_page).records
      if  user_id
        MixpanelDelayedTracker.perform_later(user_id,
                                             'search',
                                             term: query,
                                             result_count: products.count)
      end
      # products_search_result = Product.search(query: query, per_page: per_page, page: page)
      # products = products_search_result.map do |result|
      #   # Let's fake an AR product.
      #   p = Product.new(uuid: result.uuid,
      #                   title: result.title,
      #                   category: result.category,
      #                   description: result.description,
      #                   status: result.status)
      #   p.id = result.id
      #   p.user_id = result.user_id
      #   p
      # end
      # products = Kaminari.
      #            paginate_array(products, total_count: products_search_result.total_count).
      #            page(page).
      #            per(per_page)
      self.success_result = products
    end
  end
end
