module Users
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

    attr_accessor :success_result, :id

    def initialize(params = {})
      @id = params.fetch(:id)
    end

    def generate_result!
      user = User.find_by_uuid(id)
      if user
        self.success_result = user
      else
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end
  end
end
