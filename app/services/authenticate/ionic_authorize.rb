require 'jwt'

module Authenticate
  class IonicAuthorize

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :token, :state, :redirect_uri, presence: true, strict: ApiError::FailedValidation

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {})
      service = new(params)
      service.valid?
      service.generate_result!
      service
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :success_result, :token, :state, :redirect_uri

    def initialize(params = {})
      @token = params[:token]
      @state = params[:state]
      @redirect_uri = params[:redirect_uri]
    end

    def generate_result!
      data_raw, * = JWT.decode(token,
                               hmac_secret,
                               true,
                               algorithm: 'HS256')
      data_payload = data_raw['data']
      # Ionic sends username in the field, but the client
      # should be sending emails to the backend in this field
      fail ApiError::Unauthorized, 'Invalid JWT token' unless data_payload
      email_or_username = data_payload['username']
      password = data_payload['password']
      user = User.find_by_email(email_or_username)
      user ||= User.find_by_username(email_or_username)
      fail ApiError::NotFound, I18n.t('user.errors.invalid_username') unless user
      fail ApiError::Unauthorized, I18n.t('user.errors.invalid_password') unless user.valid_password?(password)
      payload = { user_id: user.uuid }
      response_token = JWT.encode(payload, hmac_secret, 'HS256')
      response_query = { token: response_token, state: state }.to_query
      self.success_result = "#{redirect_uri}?#{response_query}"
    rescue JWT::VerificationError
      raise ApiError::Unauthorized, 'Invalid JWT token'
    end

    private

    def hmac_secret
      Rails.application.secrets.ionic_jwt_secret
    end
  end
end
