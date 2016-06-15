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
    validate :valid_user
    validates :data, :attributes, :type, :id, presence: true,
                                              strict: ApiError::FailedValidation


    RESOURCE_TYPE = 'users'

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {})
      service = new(params)
      service.generate_result!
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :type, :attributes, :data, :id, :bank_account_attributes

    def initialize(params = {})
      @id = params[:id]
      @data = params[:data]
      @attributes = data[:attributes] if data
      @bank_account_attributes = attributes[:bank_account]
      @type = data[:type] if data
      valid?
    end

    def generate_result!
      fetched_profile_attributes = attributes.slice(*profile_attributes)
      update_bank_account if bank_account_attributes
      user.profile.update_attributes(fetched_profile_attributes)
      true
    end

    private

    def update_bank_account
      new_bank_account = user
                         .profile
                         .build_bank_account(bank_account_attributes)
      new_bank_account.valid?
      new_bank_account.save
    end

    def user
      @user ||= User.find_by_uuid(id)
    end

    def valid_user
      return if user
      fail ApiError::NotFound, I18n.t('user.errors.not_found')
    end

    def valid_bank_account
    end

    def profile_attributes
      [:first_name, :last_name, :bio, :website, :country, :username]
    end

    def type_is_users
      unless type == RESOURCE_TYPE
        fail ApiError::FailedValidation, I18n.t('errors.invalid_type',
                                                type: type,
                                                resource_type: RESOURCE_TYPE)
      end
    end
  end
end
