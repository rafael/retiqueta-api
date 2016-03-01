require 'ar_uuid_generator'

class LineItem < ActiveRecord::Base
  ##################
  ## associations ##
  ##################

  belongs_to :order, primary_key: :uuid

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
