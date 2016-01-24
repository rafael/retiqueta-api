require "token_generator"

module PasswordResets
  class Create
    include ActiveModel::Validations

    RESOURCE_TYPE = "users"

    # SecureRandom.urlsafe_base64(n=nil, padding=false)
    # The argument n specifies the length, in bytes, of the random number to be generated.
    # The length of the result string is about 4/3 of n.
    # If n is not specified or is nil, 16 is assumed. It may be larger in future.
    RANDOM_NUMBER_LENGTH = 36

    validates :type, :email, presence: true, strict: ApiError::FailedValidation
    validate :type_is_users
    validate :valid_user

    attr_reader :type, :email, :user

    def self.call(params)
      service = self.new(params)
      service.generate_result!
      service
    end

    def initialize(params)
      data = params.fetch(:data, {})
      attributes = data.fetch(:attributes, {})
      @type = data[:type]
      @email = attributes[:email]
      @user = User.find_by(email: email) unless email.blank?
      validate
    end

    def generate_token
      TokenGenerator.new(User, :password_reset_token).generate
    end

    def current_utc_datetime
      DateTime.now.utc
    end

    def generate_result!
      raw_token, enc_token = generate_token
      user.password_reset_token = enc_token
      user.password_reset_sent_at = current_utc_datetime
      user.save
      UserMailer.password_reset_email(user, raw_token).deliver_later
    end

    private

    def valid_user
      unless user
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end

    def type_is_users
      unless type == RESOURCE_TYPE
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_type", type: type, resource_type: RESOURCE_TYPE))
      end
    end
  end
end
