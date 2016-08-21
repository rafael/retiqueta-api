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
            token: '4dd8feed647c7ec0c71bf1e95eaaa27b',
            payment_method_id: 'visa'
          },
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
    params_new_token = params
    params_new_token[:data][:attributes][:payment_data][:token] = '6f672e551d53cb5db6d29c8b5e9f0bc3'
    post '/v1/orders', params_new_token, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    get '/v1/orders', {}, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(200)
    expect(json['data'].first['attributes']['total_amount']).to eq(product.price)
    expect(json['data'].first['attributes']['financial_status']).to eq('paid')
    expect(json['data'].first['attributes']['currency']).to eq('VEF')
    expect(json['data'].first['attributes']['created_at']).to eq(Order.last.created_at.iso8601)
    expect(json['data'].first['attributes']['payment_info']['payment_method']).to eq('visa')
    expect(json['data'].first['attributes']['payment_info']['type']).to eq('credit_card')
    expect(json['data'].first['attributes']['payment_info']['last_four']).to eq(3704)
    expect(json['data'].first['attributes']['payment_info']['expiration_year']).to eq(2017)
    expect(json['data'].first['attributes']['payment_info']['expiration_month']).to eq(12)
    expect(json['data'].first['attributes']['payment_info']['cardholder_name']).to eq('APRO Rafael')
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
    params_new_token = params
    params_new_token[:data][:attributes][:payment_data][:token] = '8acce807606019c1414bd4da1989d096'
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
    params_new_token = params
    params_new_token[:data][:attributes][:payment_data][:token] = '226feae41c5e9fbe3fc163f948e2a501'
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    id = json['data']['id']
    get "/v1/orders/#{id}",
        {},
        'X-Authenticated-Userid' => seller.uuid
    expect(response.status).to eq(200)
  end

  it "can't get an order if it's not a buyer or seller" do
    params_new_token = params
    params_new_token[:data][:attributes][:payment_data][:token] = 'e7dc59e2aefbfdd8a1bfc40e0d407abc'
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    id = json['data']['id']
    get "/v1/orders/#{id}",
        {},
        'X-Authenticated-Userid' => random_user.uuid
    expect(response.status).to eq(404)
  end
end
