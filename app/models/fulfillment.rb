class Fulfillment < ActiveRecord::Base
  belongs_to :order, primary_key: :uuid
  has_one :conversation, as: :commentable
  delegate :comments, to: :conversation


  ###############
  ## Callbacks ##
  ###############

  before_create :generate_uuid
  before_create :generate_converstation

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def generate_converstation
    conversation || build_conversation
  end
end
