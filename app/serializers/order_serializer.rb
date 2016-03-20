class OrderSerializer < ActiveModel::Serializer

  attributes :id, :shipping_address, :total_amount, :financial_status

  has_many :line_items
  has_one :fulfillment
  belongs_to :user, serializer: PublicUserSerializer

  def id
    object.uuid
  end
end
