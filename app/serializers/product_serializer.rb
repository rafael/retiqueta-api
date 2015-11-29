class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :category, :original_price, :currency

  has_many :product_pictures
  belongs_to :user, serializer: PublicUserSerializer

  def id
    object.uuid
  end
end
