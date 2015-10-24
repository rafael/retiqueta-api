class User < ActiveRecord::Base

  ###############
  ## Callbacks ##
  ###############

  before_create :generate_uuid
  before_create :initialize_profile

  ################
  ## Extensions ##
  ################

  acts_as_authentic do |c|
    c.require_password_confirmation = false
  end

  ##################
  ## associations ##
  ##################

  has_one :profile

  delegate :pic, :first_name, :last_name, :bio, :website, to: :profile

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def initialize_profile
    build_profile
  end
end
