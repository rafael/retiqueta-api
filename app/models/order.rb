require 'ar_uuid_generator'

class Order < ActiveRecord::Base

  PAID_STATUS = 'paid'

  ##################
  ## associations ##
  ##################

  belongs_to :user, primary_key: :uuid
  has_one :conversation, as: :commentable
  has_one :payment_transaction
  has_many :line_items, primary_key: :uuid
  delegate :comments, to: :conversation

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
