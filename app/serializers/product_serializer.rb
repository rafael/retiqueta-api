class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :category, :original_price,
             :currency, :size, :price, :comments_count, :likes_count,
             :location, :lat_lon, :status

  has_many :product_pictures
  has_many :comments, serializer: TextCommentSerializer

  belongs_to :user, serializer: PublicUserSerializer

  def id
    object.uuid
  end

  def comments
    object.comments.order('created_at asc').limit(10)
  end

  def comments_count
    object.comments.count
  end

  def likes_count
    object.get_likes.count
  end

  meta do
    {
      liked_by_current_user: current_user && current_user.liked?(object),
      followed_by_current_user: current_user && current_user.following?(object.user)
    }
  end
end
