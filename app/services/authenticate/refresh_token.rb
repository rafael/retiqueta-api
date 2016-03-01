module Authenticate
  class RefreshToken

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :refresh_token, :client_id, presence: true, strict: ApiError::FailedValidation

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

    attr_accessor :success_result, :status, :refresh_token, :client_id

    def initialize(params = {})
      @refresh_token = params[:refresh_token]
      @client_id = params[:client_id]
      valid?
    end

    def generate_result!
      response = kong_client.post Rails.configuration.x.kong.users_ouath_token_path, URI.encode_www_form(kong_request_body)
      self.success_result = response.body
      self.status = response.status
    end

    private

    def kong_request_body
      {
        client_secret: Rails.application.secrets.kong_client_secret,
        client_id: Rails.application.secrets.kong_client_id,
        refresh_token: refresh_token,
        provision_key: Rails.application.secrets.kong_client_provision_key,
        grant_type: 'refresh_token',
        scope: 'app',
      }
    end

    def kong_client
      headers = {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Accept' => 'application/json',
      }
      conn_options = {
        url: Rails.configuration.x.kong.internal_url,
        headers: headers,
        ssl: { verify: false }
      }
      @conn ||= Faraday.new(conn_options) do |connection|
        connection.adapter Faraday.default_adapter
      end
    end
  end
end
