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
      user =  User.find_by_email(login)
      user ||= User.find_by_username(login)
      if user && user.valid_password?(password)
        body =  {
          client_secret: "c4c6f41e11294965c998379111143ba8",
          client_id: "ret-mobile-ios",
          scope: 'app',
          provision_key: 'a2a1ed0c2ef64868c85fa56e5770831a',
          grant_type: 'password',
          authenticated_userid: user.uuid
        }

        response = kong_client.post '/users/oauth2/token', URI.encode_www_form(body)
        self.success_result = response.body
        self.status = response.status
      else
        self.status = 400
        self.errors.add(:base, 'Invalid username or password')
      end
    end

    def failure_result
      @failure_result ||= ApiError.new(title: ApiError.title_for_error(ApiError::FAILED_VALIDATION),
                                       code: ApiError::FAILED_VALIDATION,
                                       detail: errors.full_messages.join(', '))
    end

    private

    def kong_client
      headers = {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Accept' => 'application/json',
      }
      conn_options = {
        url: 'https://kong:8443',
        headers: headers,
        ssl:  {verify: false}
      }
      @conn ||= Faraday.new(conn_options) do |connection|
        connection.adapter Faraday.default_adapter
      end
    end
  end
end
