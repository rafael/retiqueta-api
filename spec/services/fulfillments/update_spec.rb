require 'rails_helper'

RSpec.describe Fulfillments::Update, type: :model do
  let(:buyer) { create(:user) }
  let(:seller) { create(:user) }
  let(:random_user) { create(:user) }
  let(:product_1) { create(:product, user: seller, price: 10) }
  let(:product_2) { create(:product, user: seller, price: 20) }

  let(:dummy_payment_provider) do
    payment_provider = double('PaymentProviders')
    mp_ve = double('mercado_pago_sdk')
    allow(mp_ve).to receive(:post).and_return('status' => '201',
                                              'response' => { 'status' => 'approved' })
    allow(payment_provider).to receive(:mp_ve).and_return(mp_ve)
    payment_provider
  end

  let(:default_dependencies) do
    {
      payment_providers: dummy_payment_provider
    }
  end

  let(:valid_line_item_1) do
    {
      product_type: 'products',
      product_id: product_1.uuid
    }
  end

  let(:valid_line_item_2) do
    {
      product_type: 'products',
      product_id: product_2.uuid
    }
  end

  let(:params) do
    {
      user_id: buyer.uuid,
      data: {
        type: 'orders',
        attributes: {
          payment_data: { token: 'token', payment_method_id: 'visa' },
          line_items: [valid_line_item_1, valid_line_item_2]
        }
      }
    }
  end

  let(:fulfillment_params) do
    {
      user_id: seller.uuid,
      fulfillment_id: order.fulfillment.uuid,
      data: {
        type: 'fulfillments',
        attributes: {
          status: Fulfillment::SENT_STATUS
        }
      }
    }
  end

  let(:order) do
    Orders::Create.call(params, default_dependencies)
    Order.last
  end

  it 'sets status to sent from seller' do
    described_class.call(fulfillment_params)
    expect(order.reload.fulfillment.status).to eq(Fulfillment::SENT_STATUS)
  end

  it "can't set status to sent if is already set" do
    fulfillment = order.fulfillment
    fulfillment.status = 'sent'
    fulfillment.save
    expect do
      described_class.call(fulfillment_params)
    end.to raise_error(ApiError::FailedValidation)
  end

  it "can't set status to delivered if is already set" do
    fulfillment = order.fulfillment
    fulfillment.status = Fulfillment::DELIVERED_STATUS
    fulfillment.save
    buyer_params = fulfillment_params
    buyer_params[:user_id] = buyer.uuid
    buyer_params[:data][:attributes][:status] = Fulfillment::DELIVERED_STATUS
    expect do
      described_class.call(buyer_params)
    end.to raise_error(ApiError::FailedValidation)
  end

  it 'sets status to delivered from buyer' do
    fulfillment = order.fulfillment
    fulfillment.status = 'sent'
    fulfillment.save
    buyer_params = fulfillment_params
    buyer_params[:user_id] = buyer.uuid
    buyer_params[:data][:attributes][:status] = Fulfillment::DELIVERED_STATUS
    described_class.call(buyer_params)
    expect(order.reload.fulfillment.status).to eq(Fulfillment::DELIVERED_STATUS)
  end

  it "random user can't set status" do
    fulfillment = order.fulfillment
    fulfillment.status = 'sent'
    fulfillment.save
    buyer_params = fulfillment_params
    buyer_params[:user_id] = random_user.uuid
    buyer_params[:data][:attributes][:status] = Fulfillment::DELIVERED_STATUS
    expect do
      described_class.call(fulfillment_params)
    end.to raise_error(ApiError::Unauthorized)
  end
end
