class OrderSerializer < ActiveModel::Serializer

  attributes :id, :shipping_address, :total_amount, :financial_status

  def id
    object.uuid
  end
end
