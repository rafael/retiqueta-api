require 'rails_helper'
require 'set'

RSpec.describe 'Sales Requests', vcr: true, type: :request do
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

  it 'show index of sales' do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    sale = Sale.last
    expect(response.status).to eq(201)
    get '/v1/sales', {}, 'X-Authenticated-Userid' => seller.uuid
    expect(response.status).to eq(200)
    expect(json['data'].first['attributes']['amount']).to eq(sale.amount)
    expect(json['data'].first['attributes']['store_fee']).to eq(sale.store_fee)
  end

  it 'show index of sales with included relationships' do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    included_sub_resources = [
      'order',
      'order.line_items',
      'order.line_items.product',
      'order.line_items.product.product_pictures',
      'order.user',
      'order.fulfillment'
    ]
    get '/v1/sales',
        { include: included_sub_resources.join(',')},
        'X-Authenticated-Userid' => seller.uuid
    expect(response.status).to eq(200)
    sub_resource_types =
      json['included'].map { |sub_resource| sub_resource['type'] }
    expect(sub_resource_types.to_set).to eq(Set.new(['orders',
                                                     'line_items',
                                                     'products',
                                                     'product_pictures',
                                                     'fulfillments',
                                                     'users']))
  end

  it 'gets a sales with included relationships', truncate: true do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    id = Sale.last.uuid
    included_sub_resources = [
      'order',
      'order.line_items',
      'order.line_items.product',
      'order.line_items.product.product_pictures',
      'order.user',
      'order.fulfillment'
    ]
    get "/v1/sales/#{id}",
        { include: included_sub_resources.join(',')},
        'X-Authenticated-Userid' => seller.uuid
    expect(response.status).to eq(200)
    sub_resource_types =
      json['included'].map { |sub_resource| sub_resource['type'] }
    expect(sub_resource_types.to_set).to eq(Set.new(['orders',
                                                     'line_items',
                                                     'products',
                                                     'product_pictures',
                                                     'fulfillments',
                                                     'users']))
  end

  it "can't get a sale if it's not the seller", truncate: true do
    post '/v1/orders', params, 'X-Authenticated-Userid' => buyer.uuid
    expect(response.status).to eq(201)
    id = Sale.last.uuid
    get "/v1/sales/#{id}",
        {},
        'X-Authenticated-Userid' => random_user.uuid
    expect(response.status).to eq(404)
  end
end
