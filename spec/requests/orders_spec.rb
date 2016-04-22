require 'rails_helper'
require 'set'

RSpec.describe 'Orders Requests', vcr: true, type: :request do
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
            token: '6ecea994186748ba94649878637af8fc',
            payment_method_id: 'visa'
          },
          shipping_address: '2930 Lyon Street - Apt 2A, San Francisco, CA, 94123',
          line_items: [valid_line_item]
        }
      }
    }
  end

  it 'creates an order' do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
  end

  it 'show index of orders' do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    get '/v1/orders', {}, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(200)
    expect(json['data'].first['attributes']['shipping_address']).to eq('2930 Lyon Street - Apt 2A, San Francisco, CA, 94123')
    expect(json['data'].first['attributes']['total_amount']).to eq(product.price)
    expect(json['data'].first['attributes']['financial_status']).to eq('paid')
    expect(json['data'].first['attributes']['currency']).to eq('VEF')
    expect(json['data'].first['attributes']['created_at']).to eq(Order.last.created_at.iso8601)
    expect(json['data'].first['attributes']['payment_method']).to eq('visa')
  end

  it 'show index of orders with included relationships' do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    included_sub_resources = ['line_items',
                              'line_items.product',
                              'line_items.product.product_pictures',
                              'user',
                              'fulfillment']
    get '/v1/orders',
        { include: included_sub_resources.join(',')},
        'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(200)
    sub_resource_types =
      json['included'].map { |sub_resource| sub_resource['type'] }
    expect(sub_resource_types.to_set).to eq(Set.new(['line_items',
                                                     'products',
                                                     'product_pictures',
                                                     'fulfillments',
                                                     'users']))
  end

  it 'gets an order with included relationships' do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    id = json['data']['id']
    included_sub_resources = ['line_items',
                              'line_items.product',
                              'line_items.product.product_pictures',
                              'user',
                              'fulfillment']
    get "/v1/orders/#{id}",
        { include: included_sub_resources.join(',')},
        'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(200)
    sub_resource_types =
      json['included'].map { |sub_resource| sub_resource['type'] }
    expect(sub_resource_types.to_set).to eq(Set.new(['line_items',
                                                     'products',
                                                     'product_pictures',
                                                     'fulfillments',
                                                     'users']))
  end

  it 'seller can get order' do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    id = json['data']['id']
    get "/v1/orders/#{id}",
        {},
        'X-Authenticated-Userid' => seller.uuid
    expect(response.status).to eq(200)
  end

  it "can't get an order if it's not a buyer or seller" do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    id = json['data']['id']
    get "/v1/orders/#{id}",
        {},
        'X-Authenticated-Userid' => random_user.uuid
    expect(response.status).to eq(404)
  end
end
