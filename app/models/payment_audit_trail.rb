require 'ar_uuid_generator'

class PaymentAuditTrail < ActiveRecord::Base

  establish_connection "audit_#{Rails.env}".to_sym

  ##################
  ## associations ##
  ##################

  belongs_to :user, primary_key: :uuid

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
