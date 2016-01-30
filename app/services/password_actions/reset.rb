require "token_generator"

module PasswordActions
  class Reset
    include ActiveModel::Validations

    RESOURCE_TYPE = "users"
    TOKEN_DURATION = 1 #hours

    validates :type, :password, :token, presence: true, strict: ApiError::FailedValidation
    validate :type_is_users
    validate :valid_token

    attr_reader :type, :email, :user, :password, :token

    def self.call(params)
      service = self.new(params)
      service.generate_result!
      service
    end

    def initialize(params)
      data = params.fetch(:data, {})
      attributes = data.fetch(:attributes, {})
      @type = data[:type]
      @token = attributes[:token]
      @password = attributes[:password]

      unless token.blank?
        @user = User.find_by(password_reset_token: token_digest(token))
      end

      validate
    end

    def generate_result!
      user.password = password
      if user.valid?
        user.password_reset_token = nil
        user.password_reset_sent_at = nil
        user.save
      else
        user.errors.each { |k, v| self.errors.add(k, v) }
        raise ApiError::FailedValidation.new(errors.full_messages.join(', '))
      end
    end

    def token_digest(token)
      TokenGenerator.new(User, :password_reset_token).digest(token)
    end

    private

    def token_expired?
      user.password_reset_sent_at + TOKEN_DURATION.hours < Time.now.utc
    end

    def valid_token
      if !user || token_expired?
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_password_reset_token"))
      end
    end

    def type_is_users
      unless type == RESOURCE_TYPE
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_type", type: type, resource_type: RESOURCE_TYPE))
      end
    end
  end
end
