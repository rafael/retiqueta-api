require 'ar_uuid_generator'

class LineItem < ActiveRecord::Base
  ##################
  ## associations ##
  ##################

  belongs_to :order, primary_key: :uuid
  belongs_to :product, polymorphic: true, primary_key: :uuid

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
end
