module Users
  class Update

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validate :type_is_users
    validates :data, :attributes, :type, :id, presence: true, strict: ApiError::FailedValidation

    RESOURCE_TYPE = "users"

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {})
      service = self.new(params)
      service.generate_result!
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :type, :attributes, :data, :id

    def initialize(params = {})
      @id = params[:id]
      @data = params[:data]
      @attributes = data[:attributes] if data
      @type = data[:type] if data
      valid?
    end

    def generate_result!
      user = User.find_by_uuid(id)
      if user
        profile_attributes = attributes.slice(*profile_attributes)
        user.profile.update_attributes(attributes)
        true
      else
        raise ApiError::NotFound.new(I18n.t("user.errors.not_found"))
      end
    end

    private

    def profile_attributes
      [:first_name, :last_name, :bio, :website, :country]
    end

    def type_is_users
      unless type == RESOURCE_TYPE
        raise ApiError::FailedValidation.new(I18n.t("errors.invalid_type", type: type, resource_type: RESOURCE_TYPE))
      end
    end
  end
end
