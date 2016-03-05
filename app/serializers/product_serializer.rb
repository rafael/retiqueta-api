class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :category, :original_price,
             :currency, :size, :price

  has_many :product_pictures
  has_many :comments, serializer: TextCommentSerializer

  belongs_to :user, serializer: PublicUserSerializer

  def id
    object.uuid
  end

  def comments
    object.comments.order('created_at asc').limit(10)
  end
end
