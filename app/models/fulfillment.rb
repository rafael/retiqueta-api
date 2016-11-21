require 'act_as_commentable'
require 'ar_uuid_generator'

class Fulfillment < ActiveRecord::Base

  PENDING_STATUS = 'pending'
  SENT_STATUS = 'sent'
  DELIVERED_STATUS = 'delivered'

  belongs_to :order, primary_key: :uuid
  has_one :conversation, as: :commentable
  delegate :comments, to: :conversation

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
  include ActAsCommentable
end
