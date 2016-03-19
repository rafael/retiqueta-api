require 'ar_uuid_generator'

class Order < ActiveRecord::Base

  PAID_STATUS = 'paid'

  ##################
  ## associations ##
  ##################

  belongs_to :user, primary_key: :uuid
  belongs_to :payment_transaction, primary_key: :uuid
  has_many :line_items, primary_key: :uuid
  has_one :fulfillment, primary_key: :uuid

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
