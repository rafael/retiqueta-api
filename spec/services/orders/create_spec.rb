require 'rails_helper'

RSpec.describe Orders::Create, type: :model do
  let(:buyer) { create(:user) }
  let(:seller) { create(:user) }
  let(:product_1) { create(:product, user: seller, price: 10) }
  let(:product_2) { create(:product, user: seller, price: 20) }
  let(:invalid_product) { create(:product, user: seller, price: 20, status: 'sold') }

  let(:dummy_payment_provider) do
    payment_provider = double('PaymentProviders')
    mp_ve = double('mercado_pago_sdk')
    allow(mp_ve).to receive(:post).and_return('status' => 200, 'data' => {})
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
      product_type: 'product',
      product_id: product_1.uuid,
      price: product_1.price
    }
  end

  let(:invalid_product_status_line_item) do
    {
      product_type: 'product2',
      product_id: invalid_product.uuid,
      price: invalid_product.price
    }
  end

  let(:invalid_type_line_item) do
    {
      product_type: 'product2',
      product_id: product_2.uuid,
      price: product_2.price
    }
  end

  let(:invalid_product_line_item) do
    {
      product_type: 'product',
      product_id: 'dummy-id',
      price: product_2.price
    }
  end

  let(:valid_line_item_2) do
    {
      product_type: 'product',
      product_id: product_2.uuid,
      price: product_2.price
    }
  end

  let(:params) do
    {
      user_id: buyer.uuid,
      data: {
        type: 'orders',
        attributes: {
          payment_data: { token: 'token', payment_method_id: 'visa' },
          shipping_address: '2930 Lyon Street - Apt 2A, San Francisco, CA, 94123',
          line_items: [valid_line_item_1, valid_line_item_2]
        }
      }
    }
  end

  it 'fails when the parameters are invalid' do
    expect do
      described_class.call({})
    end.to raise_error(ApiError::FailedValidation,
                       "Data can't be blank")
  end

  it 'fails when the type is invalid in a line item' do
    expect do
      invalid_params = params
      invalid_params[:data][:attributes][:line_items] =
        [valid_line_item_1, invalid_type_line_item]
      described_class.call(invalid_params)
    end.to raise_error(ApiError::FailedValidation,
                       'Invalid product type in line items')
  end

  it "fails when can't find a product in a line item" do
    expect do
      invalid_params = params
      invalid_params[:data][:attributes][:line_items] =
        [valid_line_item_1, invalid_product_line_item]
      described_class.call(invalid_params)
    end.to raise_error(ApiError::FailedValidation,
                       'Line items are empty')
  end

  it "fails when product has a state different than 'published'" do
    expect do
      invalid_params = params
      invalid_params[:data][:attributes][:line_items] =
        [valid_line_item_1, invalid_product_status_line_item]
      described_class.call(invalid_params)
    end.to raise_error(ApiError::FailedValidation,
                       'Trying to buy products that are already sold')
  end

  it 'fails when there is an error updating product status' do
    product_double = double('Product')
    allow(product_double)
      .to receive(:transaction).and_raise(ActiveRecord::Rollback)
    allow(product_double)
      .to receive(:where)
      .with(uuid: [product_1.uuid, product_2.uuid])
      .and_return([product_1, product_2])

    expect do
      described_class.call(params, product_ar_interface: product_double)
    end.to raise_error(ApiError::InternalServer,
                       'Sorry, something went wrong while processing your order')
  end

  it 'creates an order' do
    service_result = described_class.call(params, default_dependencies)
    order = service_result.success_result
    expect(service_result).to_not be_nil
    expect(order).to eq(Order.last)
    expect(order.total_amount).to eq(product_1.price + product_2.price)
  end

  it 'payment audit trail corresponds to payment transaction' do
    service_result = described_class.call(params, default_dependencies)
    expect(service_result).to_not be_nil
    order = service_result.success_result
    expect(order.payment_transaction).to_not be_nil
    audit_trails =
      PaymentAuditTrail.where(payment_transaction_id: order.payment_transaction_id)
    expect(audit_trails.count).to eq(2)
    expect(audit_trails.map(&:action)).to eq(['attempting_to_charge_card',
                                              'credit_card_succesfully_charged'])
  end
end
