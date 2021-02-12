class MercadoPagoBillingProfile < ActiveModelSerializers::Model
  attr_accessor :id, :card_id, :customer_id, :payment_method, :last_four_digits
end
