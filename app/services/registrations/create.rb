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
    validates :data, :attributes, :type, :email, :password, presence: true, strict: ApiError::FailedValidation

    RESOURCE_TYPE = "users"

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

    attr_accessor :success_result, :type, :password, :email, :username, :attributes, :data

    def initialize(params = {})
      @data = params[:data]
      @attributes = data[:attributes]
      @type = data[:type]
      @email = attributes[:email]
      @username = attributes[:username]
      @password = attributes[:password]
      valid?
    end

    def generate_result!
      user = User.new(attributes.except(:password))
      user.username = username_from_email unless user.username
      user.password = password
      user.build_profile.country = "VE"
      if user.valid? && user.save
        UserMailer.signup_email(user).deliver_later
        AccountBootstrap.perform_later(user)
        Librato.increment 'user.signup.success'
        self.success_result = user
      else
        Librato.increment 'user.signup.failure'
        user.errors.each do |k, v|
          self.errors.add(k, v)
        end
        raise ApiError::FailedValidation.new(errors.full_messages.join(', '))
      end
    end

    private

    def username_from_email
      "#{email.split('@').first.tr('^A-Za-z0-9', '')}#{rand(10_000)}"
    end

    def type_is_users
      unless type == RESOURCE_TYPE
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_type", type: type, resource_type: RESOURCE_TYPE))
      end
    end
  end
end
