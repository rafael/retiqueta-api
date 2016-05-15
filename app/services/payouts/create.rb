module Payouts
  class Create
    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :data,
              :attributes,
              :type,
              :amount,
              :user_id,
              presence: true, strict: ApiError::FailedValidation

    validates :amount,
              numericality: { greater_than: 0 },
              strict: ApiError::FailedValidation

    validate :type_is_payouts
    validate :valid_user

    RESOURCE_TYPE = 'payouts'

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

    attr_accessor :type,
                  :attributes,
                  :data,
                  :amount,
                  :user_id

    def initialize(params = {})
      @user_id = params[:user_id]
      @data = params[:data] || {}
      @attributes = data[:attributes] || {}
      @type = data[:type]
      @amount = attributes[:amount].try(&:to_f)
      valid?
    end

    def generate_result!
      valid_amount
      Payout.create(user: user,
                    amount: amount,
                    status: Payout::PROCESSING_STATUS)
    end

    private

    def valid_amount
      # There will be a race condition here between the moment we check this
      # condition and the moment we commit the payout. We will solve this when
      # the time comes.
      return if user.available_balance >= amount
      fail(ApiError::FailedValidation,
           I18n.t('payouts.errors.insufficient_funds'))
    end

    def type_is_payouts
      return if type == RESOURCE_TYPE
      fail(ApiError::FailedValidation,
           I18n.t('errors.invalid_type',
                  type: type, resource_type: RESOURCE_TYPE))
    end

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def valid_user
      return if user
      fail(ApiError::NotFound, I18n.t('user.errors.not_found'))
    end
  end
end
