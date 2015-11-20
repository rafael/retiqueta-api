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

  has_one :profile, autosave: true
  has_many :products, primary_key: :uuid

  delegate :pic, :first_name, :last_name, :bio, :website, :country, to: :profile

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def initialize_profile
    # only build profile if it hasn't been set.
    profile || build_profile
  end
end
