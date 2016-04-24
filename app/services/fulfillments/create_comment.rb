module Fulfillments
  class CreateComment
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
              :user_id,
              :fulfillment_id,
              :data,
              :text,
              presence: true, strict: ApiError::FailedValidation

    validate :valid_type
    validate :valid_user
    validate :valid_fulfillment

    RESOURCE_TYPE = 'text_comments'

    ###################
    ## Class Methods ##
    ###################

    def self.call(params = {})
      service = new(params)
      service.generate_result!
      service
    end

    ######################
    ## Instance Methods ##
    ######################

    attr_accessor :success_result, :type, :attributes, :data, :user_id, :text, :fulfillment_id

    def initialize(params = {})
      @fulfillment_id = params[:fulfillment_id]
      @user_id = params[:user_id]
      @data = params[:data]
      @attributes = data[:attributes] || {}
      @type = data[:type]
      @text = attributes[:text]
      valid?
    end

    def generate_result!
      comment = fulfillment.comments.build(user: user, data: data.to_json, user_pic: user.pic.url(:small))
      comment.save!
      self.success_result = comment
    end

    private

    def valid_type
      unless type == RESOURCE_TYPE
        fail ApiError::FailedValidation.new(I18n.t('errors.invalid_type', type: type, resource_type: RESOURCE_TYPE))
      end
    end

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def fulfillment
      @fulfillment ||= Fulfillment.find_by_uuid(fulfillment_id)
    end

    def valid_fulfillment
      unless fulfillment
        fail ApiError::NotFound.new(I18n.t('fulfillment.errors.not_found'))
      end
    end

    def valid_user
      fail ApiError::NotFound.new(I18n.t('user.errors.not_found')) unless user
    end
  end
end
