require 'rails_helper'

RSpec.describe 'Products', type: :request do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user, password: '123456') }
  let(:product) { create(:product, user: seller) }

  let(:valid_line_item) do
    {
      product_type: 'product',
      product_id: product.uuid
    }
  end

  let(:params) do
    {
      data: {
        type: 'orders',
        attributes: {
          payment_data: {
            token: '67191d98cf4538cfaef81b46ec9af838',
            payment_method_id: 'visa'
          },
          shipping_address: '2930 Lyon Street - Apt 2A, San Francisco, CA, 94123',
          line_items: [valid_line_item]
        }
      }
    }
  end

  it 'creates an product', vcr: true do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
  end
end
