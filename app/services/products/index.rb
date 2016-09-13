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
      @per_page = page[:size] || 25
      @page = page[:number] || 1
    end

    def generate_result!
      merched_ids = AppClients.redis.lrange("merched_ids", 0, -1)
      products = Product
                 .where('featured = ? or id in (?)', true, merched_ids)
                 .order(created_at: :desc)
                 .page(page)
                 .per(per_page)
      self.success_result = products
    end
  end
end
