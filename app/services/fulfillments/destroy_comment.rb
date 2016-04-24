module Fulfillments
  class DestroyComment
    #################
    ## Extensions  ##
    #################

    include ActiveModel::Validations

    #################
    ## Validations ##
    #################

    validates :user_id,
              :fulfillment_id,
              :comment_id,
              presence: true, strict: ApiError::FailedValidation

    validate :valid_user
    validate :valid_fulfillment
    validate :valid_comment

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

    attr_accessor :user_id, :fulfillment_id, :comment_id

    def initialize(params = {})
      @fulfillment_id = params[:fulfillment_id]
      @comment_id = params[:id]
      @user_id = params[:user_id]
      valid?
    end

    def generate_result!
      unless comment.user == user
        fail ApiError::Unauthorized.new(I18n.t('errors.messages.unauthorized'))
      end
      comment.destroy!
    end

    private

    def user
      @user ||= User.find_by_uuid(user_id)
    end

    def fulfillment
      @fulfillment ||= Fulfillment.find_by_uuid(fulfillment_id)
    end

    def comment
      @comment ||= fulfillment.comments.where(uuid: comment_id).first
    end

    def valid_fulfillment
      unless fulfillment
        fail ApiError::NotFound.new(I18n.t('fulfillment.errors.not_found'))
      end
    end

    def valid_user
      fail ApiError::NotFound.new(I18n.t('user.errors.not_found')) unless user
    end

    def valid_comment
      unless comment
        fail ApiError::NotFound.new(I18n.t('comment.errors.not_found'))
      end
    end
  end
end
