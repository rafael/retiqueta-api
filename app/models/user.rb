class User < ActiveRecord::Base
  before_create :generate_uuid

  acts_as_authentic do |c|
    c.require_password_confirmation = false
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
