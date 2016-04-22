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

  delegate :payment_method, to: :payment_transaction

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator

  def sellers
    line_items.map(&:product).map(&:user)
  end
end
