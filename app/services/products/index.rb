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
      # This should be deprecated
      products = Product
                 .where(featured: true)
                 .order(created_at: :desc)
                 .page(page)
                 .per(per_page)
      self.success_result = products
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
