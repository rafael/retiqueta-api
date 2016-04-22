require 'time'

class OrderSerializer < ActiveModel::Serializer

  attributes :id, :shipping_address, :total_amount, :financial_status,
             :created_at, :currency, :payment_method

  has_many :line_items
  has_one :fulfillment
  belongs_to :user, serializer: PublicUserSerializer

  def id
    object.uuid
  end

  def created_at
    object.created_at.utc.iso8601
  end
end
