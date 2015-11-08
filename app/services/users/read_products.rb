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

    attr_accessor :id, :success_result

    def initialize(params = {})
      @id = params.fetch(:id)
    end

    def generate_result!
      products = Product.where(user_id: id)
      self.success_result = products
    end
  end
end
