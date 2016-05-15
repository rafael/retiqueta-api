require 'time'

class OrderSerializer < ActiveModel::Serializer
  attributes :id, :total_amount, :financial_status,
             :created_at, :currency, :payment_info

  has_many :line_items
  has_one :fulfillment
  belongs_to :user, serializer: PublicUserSerializer

  def id
    object.uuid
  end

  def created_at
    object.created_at.utc.iso8601
  end

  def payment_info
    {
      payment_method: object.payment_method,
      type: 'credit_card',
      last_four: last_four.to_i,
      expiration_year: expiration_year.to_i,
      expiration_month: expiration_month.to_i,
      cardholder_name: cardholder_name
    }
  end

  private

  def last_four
    JSON.parse(object.payment_transaction.metadata)['response']['card']['last_four_digits']
  rescue
    'unknown'
  end

  def expiration_year
    JSON.parse(object.payment_transaction.metadata)['response']['card']['expiration_year']
  rescue
    'unknown'
  end

  def expiration_month
    JSON.parse(object.payment_transaction.metadata)['response']['card']['expiration_month']
  rescue
    'unknown'
  end

  def cardholder_name
    JSON.parse(object.payment_transaction.metadata)['response']['card']['cardholder']['name']
  rescue
    'unknown'
  end
end
