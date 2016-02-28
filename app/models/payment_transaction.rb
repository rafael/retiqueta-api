require 'ar_uuid_generator'

class PaymentTransaction < ActiveRecord::Base
  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
