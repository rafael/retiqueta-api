class Conversation < ActiveRecord::Base

  ##################
  ## associations ##
  ##################

  belongs_to :commentable, polymorphic: true, dependent: :delete
  has_many :comments, -> { order(created_at: :asc) }
end
