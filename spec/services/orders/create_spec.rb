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
      product_id: product_1.uuid,
    }
  end

  let(:invalid_product_status_line_item) do
    {
      product_type: 'product2',
      product_id: invalid_product.uuid,
    }
  end

  let(:invalid_type_line_item) do
    {
      product_type: 'product2',
      product_id: product_2.uuid,
    }
  end

  let(:invalid_product_line_item) do
    {
      product_type: 'products',
      product_id: 'dummy-id',
    }
  end

  let(:valid_line_item_2) do
    {
      product_type: 'products',
      product_id: product_2.uuid,
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
                       "Couldn't find the following line items: dummy-id")
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
    product_double = double('products')
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

  it 'creates a sale' do
    seller.profile.update(store_fee: 0.2)
    service_result = described_class.call(params, default_dependencies)
    sale = Sale.last
    expect(service_result).to_not be_nil
    expect(sale).to_not be_nil
    # Amount should equal to total amount minus store fee
    expect(sale.amount).to eq((product_1.price + product_2.price) * 0.8)
    # Store fee should equal to user store_fee
    expect(sale.store_fee).to eq((product_1.price + product_2.price) * 0.2)
  end

  it 'assigns payment method to payment transaction' do
    service_result = described_class.call(params, default_dependencies)
    expect(service_result).to_not be_nil
    order = service_result.success_result
    expect(order.payment_transaction).to_not be_nil
    expect(order.payment_transaction.payment_method).to eq('visa')
  end

  it 'payment audit trail corresponds to payment transaction' do
    service_result = described_class.call(params, default_dependencies)
    expect(service_result).to_not be_nil
    order = service_result.success_result
    expect(order.payment_transaction).to_not be_nil
    audit_trails =
      PaymentAuditTrail.where(payment_transaction_id: order.payment_transaction_id)
    expect(audit_trails.count).to eq(2)
    expect(audit_trails.map(&:action).to_set).to eq(['attempting_to_charge_card',
                                                     'credit_card_succesfully_charged'].to_set)
  end

  it 'Line items are created' do
    service_result = described_class.call(params, default_dependencies)
    expect(service_result).to_not be_nil
    order = service_result.success_result
    expect(order.line_items).to_not be_nil
    expect(order.line_items.count).to eq(2)
  end

  it 'Order fulfillment gets created' do
    service_result = described_class.call(params, default_dependencies)
    expect(service_result).to_not be_nil
    order = service_result.success_result
    expect(order.fulfillment).to_not be_nil
  end

  context 'talking to MercadoPago Ve API', :vcr do
    # All the tokens in these tests were generated using the
    # following form:
    # https://gist.github.com/rafael/300799b37eebfc14e607
    it 'rejects order when card token is invalid' do
      expect do
        described_class.call(params)
      end.to raise_error(ApiError::FailedValidation,
                         "Sorry, we couldn't charge your card")
    end

    it 'charges card when token is valid' do
      # Token obtained from test js with APRO name
      valid_payment_params = params
      valid_payment_params[:data][:attributes][:payment_data] =
        { token: 'a5c098b3fa9bfe097fadf536f7478297', payment_method_id: 'visa' }
      service_result = described_class.call(valid_payment_params)
      order = service_result.success_result
      expect(service_result).to_not be_nil
      expect(order).to eq(Order.last)
    end

    it 'handles rejected by insufficient amount' do
      # Token obtained from test js with FUND
      valid_payment_params = params
      valid_payment_params[:data][:attributes][:payment_data] =
        { token: '695a34a9ef226eda2623c982492f55e2', payment_method_id: 'visa' }
      expect do
        described_class.call(params)
      end.to raise_error(ApiError::FailedValidation,
                         "Sorry, we couldn't charge your card")
    end

    it 'handles pending payment response' do
      # Token obtained from test js with CONT
      valid_payment_params = params
      valid_payment_params[:data][:attributes][:payment_data] =
        { token: '6c090c6301357cc7a32eb0d8f10bfdde', payment_method_id: 'visa' }
      service_result = described_class.call(params)
      order = service_result.success_result
      expect(service_result).to_not be_nil
      expect(order).to eq(Order.last)
    end

    it 'handles call for authorize response' do
      # Token obtained from test js with CALL
      valid_payment_params = params
      valid_payment_params[:data][:attributes][:payment_data] =
        { token: '624fb3be04aaf59eee7e4b45d1372521', payment_method_id: 'visa' }
      service_result = described_class.call(params)
      order = service_result.success_result
      expect(service_result).to_not be_nil
      expect(order).to eq(Order.last)
    end

    it 'handles rejected by expiration date' do
      # Token obtained from test js with EXPI
      valid_payment_params = params
      valid_payment_params[:data][:attributes][:payment_data] =
        { token: 'b444290109bcc4ac6b21b827f50cf7dd', payment_method_id: 'visa' }
      expect do
        described_class.call(params)
      end.to raise_error(ApiError::FailedValidation,
                         "Sorry, we couldn't charge your card")
    end

    it 'handles rejected by error in the form' do
      # Token obtained from test js with FORM
      valid_payment_params = params
      valid_payment_params[:data][:attributes][:payment_data] =
        { token: '25e48b7df721a4a98fc9e87c394c0a4f', payment_method_id: 'visa' }
      expect do
        described_class.call(params)
      end.to raise_error(ApiError::FailedValidation,
                         "Sorry, we couldn't charge your card")
    end

    it 'handles rejected by general error' do
      # Token obtained from test js with OTHE
      valid_payment_params = params
      valid_payment_params[:data][:attributes][:payment_data] =
        { token: 'b02ddecc4c23f87632dbe5e13102a1e1', payment_method_id: 'visa' }
      expect do
        described_class.call(params)
      end.to raise_error(ApiError::FailedValidation,
                         "Sorry, we couldn't charge your card")
    end
  end
end
