module Authenticate
  class FacebookConnect

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :token, :expires_in, presence: true, strict: ApiError::FailedValidation

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

    attr_accessor :success_result, :token, :expires_in, :status

    def initialize(params = {})
      @token = params[:token]
      @expires_in = params[:expires_in]
    end

    def generate_result!
      user = find_user_with_fb_profile(fb_profile)
      if user
        create_facebook_account(user) unless user.facebook_account
        authorize_user_in_kong_and_set_response(user)
      else
        new_user = setup_new_user
        create_facebook_account(new_user)
        authorize_user_in_kong_and_set_response(new_user)
      end
    end

    private

    def setup_new_user
      unless fb_profile['email']
        Rollbar.error(
          RuntimeError.new("Invalid data from facebook profile: #{fb_profile}")
        )
        fail ApiError::FailedValidation, 'Facebook is not returning email information'
      end

      Registrations::Create.call(data: {
                                   type: "users",
                                   attributes: {
                                     password: SecureRandom.uuid,
                                     email: fb_profile['email'],
                                     username: "#{fb_profile['email'].split("@").first.tr('^A-Za-z0-9', '')}#{rand(10000)}"
                                   }
                                 }).success_result

    end
    def create_facebook_account(user)
      FacebookAccount.create(user_id: user.uuid, token: token, expires_in: expires_in, uuid: fb_profile['id'])
    end

    def authorize_user_in_kong_and_set_response(user)
      response = kong_client.post(Rails.configuration.x.kong.users_ouath_token_path,
                                  URI.encode_www_form(kong_request_body(user)))
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

    def find_user_with_fb_profile(fb_profile)
      user = User.find_by_email(fb_profile['email'])
      user ||= User.find_by_facebook_id(fb_profile['id'])
      user
    end

    def fb_profile
      @fb_profile ||= graph_api.get_object('me',
                                           { fields: 'email'},
                                           api_version: 'v2.6')
    rescue Koala::Facebook::AuthenticationError
      raise ApiError::Unauthorized, I18n.t('user.errors.invalid_password')
    end

    def user_exists
      return if user
      fail(ApiError::NotFound, I18n.t('user.errors.invalid_username'))
    end

    def valid_password
      return if user.valid_password?(password)
      fail(ApiError::Unauthorized, I18n.t('user.errors.invalid_password'))
    end

    def kong_request_body(user)
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

    def graph_api
      @graph_api ||= Koala::Facebook::API.new(token)
    end
  end
end
