module ArUuidGenerator
  def self.included(klass)
    klass.before_create :generate_uuid
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
