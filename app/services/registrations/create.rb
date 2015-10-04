module Registrations
  class Create

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validate :type_is_users
    validates :data, :attributes, :type, :email, :username, :password, presence: true

    RESOURCE_TYPE = "users"

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

    attr_accessor :success_result, :failure_result, :type, :password, :email, :username, :attributes, :name, :data

    def initialize(params = {})
      @data = params[:data]
      @attributes = data[:attributes]
      @type = data[:type]
      @email = attributes[:email]
      @username = attributes[:username]
      @password = attributes[:password]
      @name = attributes[:name]
    end

    def valid?
      errors.empty? && super
    end

    def generate_result!
      user = User.new(attributes)
      if user.valid? && user.save
        self.success_result = user
      else
        user.errors.each do |k, v|
          self.errors.add(k, v)
        end
      end
    end

    def failure_result
      @failure_result ||= ApiError.new(title: ApiError.title_for_error(ApiError::FAILED_VALIDATION),
                                       code: ApiError::FAILED_VALIDATION,
                                       detail: errors.full_messages.join(', '))
    end

    private

    def type_is_users
      unless type == RESOURCE_TYPE
        self.errors.add(:type, "is invalid. Provied: #{type}, required #{RESOURCE_TYPE}")
      end
    end
  end
end
