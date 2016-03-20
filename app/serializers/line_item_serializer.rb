class LineItemSerializer < ActiveModel::Serializer
  attributes :id

  belongs_to :product, serializer: ProductSerializer

  def id
    object.uuid
  end
end
