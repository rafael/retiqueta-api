require 'ar_uuid_generator'

class PaymentAuditTrail < ActiveRecord::Base
  ##################
  ## associations ##
  ##################

  belongs_to :user, primary_key: :uuid

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
