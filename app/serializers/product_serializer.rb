class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :category, :original_price, :currency

  attribute :uuid, key: :id

  has_many :product_pictures
  belongs_to :user, serializer: PublicUserSerializer
end
