class Comment < ActiveRecord::Base

  ##################
  ## associations ##
  ##################

  belongs_to :user, primary_key: :uuid

  ###############
  ## Callbacks ##
  ###############

  before_create :generate_uuid

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
