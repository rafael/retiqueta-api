class SetupMpCustomerAndCard < ActiveJob::Base
  queue_as :default

  def perform(user, token, payment_response)
    mp_customer = if MpCustomer.where(user_id: user.uuid).first
                    MpCustomer.where(user_id: user.uuid).first
                  else
                    customer_response = create_customer_in_mp(user, payment_response)
                    MpCustomer.create!(user_id: user.uuid,
                                       payload: customer_response['response'])
                  end
    card_response = PaymentProviders.mp_ve.post("/v1/customers/#{mp_customer.payload['id']}/cards",
                                                token: token
                                               )
    fail ArgumentError, card_response unless card_response['status'] == '201'
    updated_mp_customer = PaymentProviders
                          .mp_ve.get("/v1/customers/#{mp_customer.payload['id']}")
    mp_customer.payload = updated_mp_customer['response']
    mp_customer.save
  end

  def create_customer_in_mp(user, payment_response)
    cardholder = payment_response['response']['card']['cardholder']
    data = {
      email: user.email,
      identification: {
        type: cardholder['identification']['type'],
        number: cardholder['identification']['number']
      }
    }
    customer_response = PaymentProviders.mp_ve.post('/v1/customers', data)
    fail ArgumentError, customer_response unless customer_response['status'] == '201'
    customer_response
  end
end
