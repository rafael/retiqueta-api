class FulfillmentSerializer < ActiveModel::Serializer
  attributes :id, :status

  has_many :comments, serializer: TextCommentSerializer

  def id
    object.uuid
  end
end
