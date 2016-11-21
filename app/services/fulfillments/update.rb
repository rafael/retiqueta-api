require 'fulfillment_helpers'

module Fulfillments
  class Update

    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations
    include FulfillmentHelpers

    #################
    ## Validations ##
    #################

    validates :data,
              :attributes,
              :type,
              :user_id,
              :fulfillment_id,
              :data,
              :status,
              presence: true, strict: ApiError::FailedValidation

    validate :valid_type
    validate :valid_user
    validate :valid_fulfillment
    validate :valid_status
    validate :authorize_user

    RESOURCE_TYPE = 'fulfillments'

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

    attr_accessor :fulfillment_id, :user_id, :attributes, :data, :type, :status

    def initialize(params = {})
      @user_id = params[:user_id]
      @fulfillment_id = params[:fulfillment_id]
      @data = params[:data]
      @attributes = data[:attributes] || {}
      @type = data[:type]
      @status = attributes[:status]
      valid?
    end

    def generate_result!
      fulfillment.status = attributes[:status]
      fulfillment.save!
    end

    private

    def order
      @order = fulfillment_order(fulfillment)
    end

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def fulfillment
      @fulfillment ||= Fulfillment.find_by_uuid(fulfillment_id)
    end

    def valid_type
      unless type == RESOURCE_TYPE
        fail ApiError::FailedValidation.new(I18n.t('errors.invalid_type', type: type, resource_type: RESOURCE_TYPE))
      end
    end

    def valid_fulfillment
      unless fulfillment
        raise ApiError::NotFound.new(I18n.t("fulfillments.errors.not_found"))
      end
    end

    def valid_user
      fail ApiError::NotFound.new(I18n.t('user.errors.not_found')) unless user
    end

    def authorize_user
      if !(user == buyer(order) || user == seller(order))
        raise ApiError::Unauthorized.new(I18n.t("errors.messages.unauthorized"))
      end
    end

    def valid_status
      if ![Fulfillment::SENT_STATUS, Fulfillment::DELIVERED_STATUS].include?(status)
        fail ApiError::FailedValidation.new(I18n.t('errors.invalid_type', type: status, resource_type: [Fulfillment::SENT_STATUS, Fulfillment::DELIVERED_STATUS].join(', ')))
      end

      if user == buyer(order) && fulfillment.status != Fulfillment::SENT_STATUS
        fail ApiError::FailedValidation.new(I18n.t('errors.invalid_type', type: fulfillment.status, resource_type: Fulfillment::SENT_STATUS))
      end

      if user == seller(order) && fulfillment.status != Fulfillment::PENDING_STATUS
        fail ApiError::FailedValidation.new(I18n.t('errors.invalid_type', type: fulfillment.status, resource_type: Fulfillment::PENDING_STATUS))
      end
    end
  end
end
