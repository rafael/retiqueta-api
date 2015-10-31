class Product < ActiveRecord::Base
  belongs_to :user, primary_key: :uuid
  has_many :product_pictures

  before_create :generate_uuid

  CATEGORIES = ["shoes", "garment"]

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
