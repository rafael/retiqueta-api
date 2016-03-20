class SaleSerializer < ActiveModel::Serializer
  attributes :id, :amount, :store_fee

  belongs_to :order, serializer: OrderSerializer

  def id
    object.uuid
  end
end
