require 'ar_uuid_generator'

class PaymentTransaction < ActiveRecord::Base

  PROCESSED_STATE = 'processed'

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
