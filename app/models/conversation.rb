class Conversation < ActiveRecord::Base

  ##################
  ## associations ##
  ##################

  belongs_to :commentable, polymorphic: true
  has_many :comments
end
