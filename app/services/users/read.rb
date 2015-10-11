module Users
  class Read

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {})
      service = self.new(params)
      service.generate_result! if service.valid?
      service
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :success_result, :failure_result, :id

    def initialize(params = {})
      @id = params.fetch(:id)
    end

    def valid?
      errors.empty? && super
    end

    def generate_result!
      user = User.find_by_uuid(id)
      if user
        self.success_result = user
      else
        self.errors.add(:base, 'User not found')
      end
    end

    def failure_result
      @failure_result ||= ApiError.new(title: ApiError.title_for_error(ApiError::FAILED_VALIDATION),
                                       code: ApiError::FAILED_VALIDATION,
                                       detail: errors.full_messages.join(', '))
    end
  end
end
