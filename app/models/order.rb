require 'act_as_commentable'
require 'ar_uuid_generator'

class Order < ActiveRecord::Base

  ##################
  ## associations ##
  ##################

  belongs_to :user, primary_key: :uuid
  has_one :conversation, as: :commentable
  delegate :comments, to: :conversation

  ################
  ## Extensions ##
  ################

  include ArUuidGenerator
  include ActAsCommentable
end
