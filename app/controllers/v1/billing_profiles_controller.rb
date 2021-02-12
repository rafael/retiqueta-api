class V1::BillingProfilesController < ApplicationController
  def index
    mp_customer = MpCustomer.where(user_id: user_id).first
    if mp_customer
      mp_profile = MercadoPagoBillingProfile.new(
        id: mp_customer.id,
        card_id: mp_customer.payload['cards'].first['id'],
        customer_id: mp_customer.payload['id'],
        payment_method: mp_customer.payload['cards'].first['payment_method']['id'],
        last_four_digits: mp_customer.payload['cards'].first['last_four_digits'])
      render json: [mp_profile],
             each_serializer: MercadoPagoBillingProfileSerializer,
             status: 200
    else
      render json: [],
             each_serializer: MercadoPagoBillingProfileSerializer,
             status: 200
    end
  end

  def destroy
    mp_customer = MpCustomer.where(user_id: user_id, id: params[:id]).first
    if mp_customer
      response = PaymentProviders.mp_ve.delete("/v1/customers/#{mp_customer.payload['id']}")
      if response['status'] != '200'
        fail ApiError::InternalServer, 'Error Deleting profile'
      end
      mp_customer.destroy
      render json: {}, status: 204
    else
      fail ApiError::NotFound, 'Billing profile not found'
    end
  end
end
