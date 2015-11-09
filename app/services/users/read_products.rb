module Users
  class ReadProducts

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

    attr_accessor :id, :success_result, :per_page, :page

    def initialize(params = {})
      @id = params.fetch(:user_id)
      page = params.fetch(:page) { {} }
      @per_page = page[:size] || 25
      @page = page[:number] || 1
    end

    def generate_result!
      products = Product.where(user_id: id).page(page).per(per_page)
      self.success_result = products
    end
  end
end
