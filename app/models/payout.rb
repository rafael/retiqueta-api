require 'ar_uuid_generator'

class Payout < ActiveRecord::Base

  PROCESSING_STATUS = 'processing'
  PAID_STATUS = 'paid'

  belongs_to :user, primary_key: :uuid

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
