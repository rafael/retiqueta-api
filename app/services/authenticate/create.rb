module Authenticate
  class Create

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :login, :password, presence: true

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

    attr_accessor :success_result, :failure_result, :login, :password, :status

    def initialize(params = {})
      @login = params[:login]
      @password = params[:password]
    end

    def valid?
      errors.empty? && super
    end

    def generate_result!
      if user && user.valid_password?(password)
        response = kong_client.post Rails.configuration.x.kong.users_ouath_token_path, URI.encode_www_form(kong_request_body)
        self.success_result = response.body
        self.status = response.status
      else
        self.status = 401
        self.errors.add(:base, 'Invalid username or password')
      end
    end

    def failure_result
      @failure_result ||= ApiError.new(title: ApiError.title_for_error(ApiError::FAILED_VALIDATION),
                                       code: ApiError::FAILED_VALIDATION,
                                       detail: errors.full_messages.join(', '))
    end

    private


    def user
      @user ||= begin
                  user =  User.find_by_email(login)
                  user ||= User.find_by_username(login)
                  user
                end
    end

    def kong_request_body
      {
        client_secret: Rails.application.secrets.kong_client_secret,
        client_id: Rails.application.secrets.kong_client_id ,
        scope: 'app',
        provision_key: Rails.application.secrets.kong_client_provision_key,
        grant_type: 'password',
        authenticated_userid: user.uuid
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
