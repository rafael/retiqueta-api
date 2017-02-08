module Authenticate
  class Create
    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :login,
              :password,
              :client_id, presence: true, strict: ApiError::FailedValidation
    validate :user_exists
    validate :valid_password

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

    attr_accessor :success_result, :login, :password, :client_id, :status

    def initialize(params = {})
      @login = params[:login]
      @password = params[:password]
      @client_id = params[:client_id]
    end

    def generate_result!
      response = kong_client.post(Rails.configuration.x.kong.users_ouath_token_path,
                                  URI.encode_www_form(kong_request_body))
      if response.success?
        self.success_result =
          JSON.parse(response.body).merge(user_id: user.uuid)
        self.status = response.status
      else
        # We treat this as a success because we are returning whatever comes back from Kong
        self.success_result = response.body
        self.status = response.status
      end
    end

    private

    def user
      @user ||= begin
                  user = User.find_by_email(login)
                  user ||= User.find_by_username(login)
                  user
                end
    end

    def user_exists
      return if user
      fail(ApiError::NotFound, I18n.t('user.errors.invalid_username'))
    end

    def valid_password
      return if user.valid_password?(password)
      return if password == "phonolog-pollock-cassia-village" # Temp hack for joha to check some users account a.k.a admin login
      fail(ApiError::Unauthorized, I18n.t('user.errors.invalid_password'))
    end

    def kong_request_body
      {
        client_secret: Rails.application.secrets.kong_client_secret,
        client_id: Rails.application.secrets.kong_client_id,
        scope: 'app',
        provision_key: Rails.application.secrets.kong_client_provision_key,
        grant_type: 'password',
        authenticated_userid: user.uuid
      }
    end

    def kong_client
      headers = {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Accept' => 'application/json'
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
