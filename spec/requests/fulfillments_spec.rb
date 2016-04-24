require 'rails_helper'
require 'set'

RSpec.describe 'Fulfillments Requests', vcr: true, type: :request do
  let(:random_user) { create(:user) }
  let(:seller) { create(:user) }
  let(:buyer) { create(:user, password: '123456') }
  let(:product) { create(:product, user: seller) }

  let(:valid_line_item) do
    {
      product_type: 'products',
      product_id: product.uuid
    }
  end

  let(:params) do
    {
      data: {
        type: 'orders',
        attributes: {
          payment_data: {
            token: '811bf876deda0bfb408dd69c7c1eef39',
            payment_method_id: 'visa'
          },
          shipping_address: '2930 Lyon Street - Apt 2A, San Francisco, CA, 94123',
          line_items: [valid_line_item]
        }
      }
    }
  end

  let(:comment_params) do
    {
      product_id: product.uuid,
      data: {
        type: 'text_comments',
        attributes: {
          text: 'Hey I like your shoes @rafael'
        }
      }
    }
  end

  it 'creates a comment in a fulfillment' do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    fulfillment_id = json['data']['relationships']['fulfillment']['data']['id']
    post "/v1/fulfillments/#{fulfillment_id}/relationships/comments",
         comment_params,
         'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
  end

  it 'shows comment index for fulfillment' do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    fulfillment_id = json['data']['relationships']['fulfillment']['data']['id']
    post "/v1/fulfillments/#{fulfillment_id}/relationships/comments",
         comment_params,
         'X-Authenticated-Userid' => buyer.uuid
    get "/v1/fulfillments/#{fulfillment_id}/relationships/comments",
        {}, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(200)
    expect(json['data'].count).to eq(1)
  end

  it 'destroys a comment in a fulfillment' do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    fulfillment_id = json['data']['relationships']['fulfillment']['data']['id']
    post "/v1/fulfillments/#{fulfillment_id}/relationships/comments",
         comment_params,
         'X-Authenticated-Userid' => buyer.uuid
    comment_id = json['data']['id']
    delete "/v1/fulfillments/#{fulfillment_id}/relationships/comments/#{comment_id}",
           {},
           'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(204)
  end
end
