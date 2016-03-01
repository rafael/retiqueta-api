require 'openssl'

class TokenGenerator
  attr_reader :klass, :column

  def initialize(klass, column, digest = "SHA256")
    @klass = klass
    @column = column
    @digest = OpenSSL::Digest.new(digest)
  end

  def digest(value)
    value.present? && OpenSSL::HMAC.hexdigest(@digest, key, value.to_s)
  end

  def generate
    loop do
      raw = friendly_token
      enc = digest(raw)
      break [raw, enc] unless klass.find_by(column.to_sym => enc)
    end
  end

  private

  def friendly_token(length = 20)
    # To calculate real characters, we must perform this operation.
    # See SecureRandom.urlsafe_base64
    rlength = (length * 3) / 4
    SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
  end

  def key
    @key ||= key_generator.generate_key("Retiqueta #{klass} #{column}")
  end

  def key_generator
    @key_generator ||= begin
      secret_key = Rails.application.secrets.secret_key_base
      key_generator = ActiveSupport::KeyGenerator.new(secret_key)
      ActiveSupport::CachingKeyGenerator.new(key_generator)
    end
  end
end
