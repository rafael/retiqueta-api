module Products
  class Read

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

    attr_accessor :success_result

    def initialize(params = {})
    end

    def generate_result!
      products = Product.where(featured: true)
      self.success_result = products
    end
  end
end
