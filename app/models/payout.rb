require 'ar_uuid_generator'

class Payout < ActiveRecord::Base

  PROCESSING_STATUS = 'processing'

  belongs_to :user, primary_key: :uuid

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
