require 'ar_uuid_generator'

class Order < ActiveRecord::Base

  ##################
  ## associations ##
  ##################

  belongs_to :user, primary_key: :uuid
  has_one :conversation, as: :commentable
  has_one :payment_transaction
  delegate :comments, to: :conversation

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
