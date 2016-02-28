require "rails_helper"

RSpec.describe Orders::Create, type: :model, focus: true do

  let(:buyer) { create(:user) }
  let(:seller) { create(:user) }
  let(:product_1) { create(:product, user: seller, price: 10) }
  let(:product_2) { create(:product, user: seller, price: 20) }

  let(:valid_line_item_1) do
    {
      product_type: 'product',
      product_id: product_1.uuid,
      price: product_1.price
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
          credit_card_token: 'token',
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

  it "fails when the type is invalid in a line item" do
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
                       "Line items are empty")
  end

  it 'creates an order', :truncate do
    service_result = described_class.call(params)
    order = service_result.success_result
    expect(service_result).to_not be_nil
    expect(order).to eq(Order.last)
    expect(order.total_amount).to eq(product_1.price + product_2.price)
  end
end
