class User < ActiveRecord::Base

  #################
  ## Validations ##
  #################

  validates :name, presence: true

  ###############
  ## Callbacks ##
  ###############

  before_create :generate_uuid


  ################
  ## Extensions ##
  ################

  acts_as_authentic do |c|
    c.require_password_confirmation = false
  end

  attr_accessor :password

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
