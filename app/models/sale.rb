require 'ar_uuid_generator'

class Sale < ActiveRecord::Base

  ##################
  ## associations ##
  ##################

  belongs_to :user, primary_key: :uuid
  belongs_to :order, primary_key: :uuid

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
