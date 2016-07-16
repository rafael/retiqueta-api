module Users
  class CreatePushToken

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validate :valid_user
    validate :valid_type

    validates :data,
              :attributes,
              :type,
              :user_id,
              :token,
              :environment,
              :platform,
              presence: true, strict: ApiError::FailedValidation

    RESOURCE_TYPE = "push_notifications"

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

    attr_accessor :user_id, :data, :attributes, :type, :environment, :platform, :device_id, :token

    def initialize(params = {})
      @user_id = params[:user_id]
      @data = params[:data] || {}
      @attributes = data[:attributes] || {}
      @type = data[:type]
      @environment = attributes[:environment]
      @platform = attributes[:platform]
      @device_id = attributes[:device_id]
      @token = attributes[:token]
      valid?
    end

    def generate_result!
      created_at = Time.now
      sql_parts = ["INSERT INTO push_tokens (user_id, uuid, platform, token, device_id, environment, created_at, updated_at) VALUES (?,?,?,?,?,?,?,?) ON CONFLICT (token, platform) DO UPDATE SET user_id = ?, environment = ?, device_id = ?, updated_at = ?", user_id, SecureRandom.uuid, platform, token, device_id, environment, created_at, created_at, user_id, environment, device_id, created_at]
      sql = PushToken.send(:sanitize_sql_array, sql_parts)
      ActiveRecord::Base.connection.execute(sql)
      #user.push_tokens.create!(attributes)
    end

    private

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def valid_type
      unless type == RESOURCE_TYPE
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_type", type: type, resource_type: RESOURCE_TYPE))
      end
    end

    def valid_user
      unless user
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end
  end
end
