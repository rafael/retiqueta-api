require 'fulfillment_helpers'

module Fulfillments
  class CreateComment
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
      send_push_notification(comment)
      self.success_result = comment
    end

    private

    def send_push_notification(comment)
      url = Rails
            .application
            .routes
            .url_helpers.v1_fulfillment_comment_url(fulfillment.uuid, comment.uuid, host: 'https://api.retiqueta.com')
      payload = {
        type: 'fulfillment_comment',
        url:  url,
        order_id: fulfillment.order.uuid
      }

      order = fulfillment_order(fulfillment)
      SendPushNotification.perform_later([user_for_notification(order)],
                                         'Retiqueta',
                                         I18n.t('comment.creation_push_notification',
                                                username: user.username,
                                                comment: text),
                                         payload)
      buyer = buyer(order)
      seller = seller(order)
      if user_for_notification(order) == buyer
        UserMailer
          .fulfillment_comment_created_for_buyer(buyer, seller, text, product_order(order))
          .deliver_later
      else
        UserMailer
          .fulfillment_comment_created_for_seller(buyer, seller, text, product_order(order))
          .deliver_later
      end
    end

    def user_for_notification(order)
      # This is a terrible hack and I should change the api to make more sense of this.
      # But basically the rule will be: It's either the seller (at the moment we only have
      # one seller per order) or the order owner
      @user_for_notification ||= begin
                                   if seller(order) == user
                                     buyer(order)
                                   else
                                     seller(order)
                                   end
                                 end
    end

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
