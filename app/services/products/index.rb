module Products
  class Index

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

    attr_accessor :success_result, :per_page, :page

    def initialize(params = {})
      page = params.fetch(:page) { {} }
      @per_page = page[:size].to_i || 25
      @page = page[:number].to_i || 1
    end

    def generate_result!
      products = Product
                 .where(featured: true)
                 .order(created_at: :desc)
                 .page(page)
                 .per(per_page)
      merched_ids = AppClients.redis.lrange("merched_ids", 0, -1)
      merched_products = Product.where(id: merched_ids)
      self.success_result = Kaminari
                            .paginate_array((merched_products.to_a[left_offset..right_offset] || []) + products.to_a,
                                            total_count: Product.count + merched_ids.count)
                            .page(page).per(per_page + merched_ids.count)
    end

    private

    def right_offset
      (page*per_page)-1
    end

    def left_offset
      0+(page-1)*per_page
    end
  end
end
