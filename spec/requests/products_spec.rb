require 'rails_helper'

RSpec.describe 'Products', type: :request do
  let(:user) { create(:user, password: '123456') }
  let(:product) { create(:product, user: user) }

  def search_response_double(product)
    search_response_double = double('search')
    expect(search_response_double).to receive(:per)
      .and_return(search_response_double)
    expect(search_response_double).to receive(:page)
      .and_return(search_response_double)
    expect(search_response_double).to receive(:records)
      .and_return(Kaminari.paginate_array([product]))
    search_response_double
  end

  let(:valid_product_picture) do
    {
      data: {
        type: 'product_pictures',
        attributes: {
          position: 0,
          pic: {
            content_type: 'image/jpeg',
            filename: 'watchmen.jpg',
            content: Base64.encode64(File.open(Rails.root.join('spec/fixtures/watchmen.jpg'), &:read))
          }
        }
      }
    }
  end

  let(:params) do
    {
      user_id: user.uuid,
      data: {
        type: 'products',
        attributes: {
          category: 'shoes',
          title: 'My awesome shoes',
          description: 'Estos zapatos tienen mucha historia conmigo',
          original_price: 60,
          price: 40,
          pictures: nil,
          size: '8',
          location: 'Caracas',
          lat_lon: "50, 20"
        }
      }
    }
  end

  it 'creates a product' do
    VCR.use_cassette('product/uploading_pic', match_requests_on: [:host, :method]) do
      post '/v1/product_pictures', valid_product_picture, 'X-Authenticated-Userid' => user.uuid
    end
    expect(response.status).to eq(201)
    picture_id = json['data']['id']
    params[:data][:attributes].merge!(pictures: [picture_id])
    post '/v1/products', params, 'X-Authenticated-Userid' => user.uuid
    expect(response.status).to eq(201)
    product_response_attributes = json['data']['attributes']
    expect(product_response_attributes['category']).to eq('shoes')
    expect(product_response_attributes['title']).to eq('My awesome shoes')
    expect(product_response_attributes['description']).to eq('Estos zapatos tienen mucha historia conmigo')
    expect(product_response_attributes['original_price']).to eq(60)
    expect(product_response_attributes['size']).to eq('8')
    expect(product_response_attributes['location']).to eq('Caracas')
    expect(product_response_attributes['lat_lon']).to eq('50, 20')
  end

  it 'product index only returns featured products' do
    product = create(:product, title: 'zapato super #nike', featured: true)
    create(:product, title: 'zapato super #nike')
    get '/v1/products'
    expect(response.status).to eq(200)
    expect(json['data'].count).to eq(1)
    expect(json['data'].first['id']).to eq(product.uuid)
  end

  it 'product index can be paginated' do
    4.times do |time|
      create(:product, title: "zapato super #{time} #nike", featured: true)
    end
    get '/v1/products', page: { number: 1, size: 1 }
    expect(response.status).to eq(200)
    expect(json['data'].count).to eq(1)
    expect(json['links']).to_not be_empty
  end

  it 'a product can be deleted' do
    delete "/v1/products/#{product.uuid}", {}, 'X-Authenticated-Userid' => user.uuid
    expect(response.status).to eq(204)
  end

  it "updates a product" do
    put "/v1/products/#{product.uuid}", params, 'X-Authenticated-Userid' => user.uuid
    expect(response.status).to eq(204)
  end

  context 'search' do
    it 'searches a product' do
      product = create(:product, title: 'zapato super #nike')
      expect(Product).to receive(:search).and_return(search_response_double(product))
      get '/v1/products/search', q: 'nike'
      expect(response.status).to eq(200)
      expect(json['data'].first['id']).to eq(product.uuid)
    end

    it 'searches a product and ignores include when invalid' do
      product = create(:product, title: 'zapato super #nike')
      expect(Product).to receive(:search).and_return(search_response_double(product))
      get '/v1/products/search', q: 'nike', include: 'product_picturexs'
      expect(response.status).to eq(200)
      expect(json['data'].first['id']).to eq(product.uuid)
      expect(json['included']).to be_nil
    end

    it 'searches a product and includes pictures when requested' do
      product = create(:product, title: 'zapato super #nike')
      expect(Product).to receive(:search).and_return(search_response_double(product))
      get '/v1/products/search', q: 'nike', include: 'product_pictures'
      expect(response.status).to eq(200)
      expect(json['data'].first['id']).to eq(product.uuid)
      expect(json['included'].count).to eq(1)
    end

    it 'searches a product and includes user when requested' do
      product = create(:product, title: 'zapato super #nike')
      expect(Product).to receive(:search).and_return(search_response_double(product))
      get '/v1/products/search', q: 'nike', include: 'user'
      expect(response.status).to eq(200)
      expect(json['data'].first['id']).to eq(product.uuid)
      expect(json['included'].count).to eq(1)
    end
  end

  context 'comments' do
    let(:params) do
      {
        user_id: user.uuid,
        product_id: product.uuid,
        data: {
          type: 'text_comments',
          attributes: {
            text: 'Hey I like your shoes @rafael'
          }
        }
      }
    end

    it 'adds a comment to a product' do
      post "/v1/products/#{product.uuid}/relationships/comments", params, 'X-Authenticated-Userid' => user.uuid
      expect(response.status).to eq(201)
      expect(json['data']['type']).to eq('text_comments')
      expect(json['data']['id']).to eq(Comment.last.uuid)
      expect(json['data']['attributes']['text']).to eq('Hey I like your shoes @rafael')
    end

    it 'fetches commments for a product' do
      post "/v1/products/#{product.uuid}/relationships/comments", params, 'X-Authenticated-Userid' => user.uuid
      get "/v1/products/#{product.uuid}/relationships/comments", params, 'X-Authenticated-Userid' => user.uuid
      expect(response.status).to eq(200)
      expect(json['data'].count).to eq(1)
    end

    it 'deletes commments for a product' do
      post "/v1/products/#{product.uuid}/relationships/comments", params, 'X-Authenticated-Userid' => user.uuid
      comment_id = json['data']['id']
      delete "/v1/products/#{product.uuid}/relationships/comments/#{comment_id}", params, 'X-Authenticated-Userid' => user.uuid
      expect(response.status).to eq(204)
    end

    it 'products can include comments' do
      post "/v1/products/#{product.uuid}/relationships/comments", params, 'X-Authenticated-Userid' => user.uuid
      post "/v1/products/#{product.uuid}/relationships/comments", params, 'X-Authenticated-Userid' => user.uuid
      get "/v1/products/#{product.uuid}", { include: 'comments' }, 'X-Authenticated-Userid' => user.uuid
      expect(response.status).to eq(200)
      expect(json['included'].size).to eq(2)
    end
  end

  context 'likes' do
    let(:params) do
      {
        user_id: user.uuid,
        product_id: product.uuid
      }
    end

    it 'adds a like to a product' do
      post "/v1/products/#{product.uuid}/like", nil, 'X-Authenticated-Userid' => user.uuid
      expect(response.status).to eq(204)
      expect(product.get_likes.count).to eq(1)
    end

    it 'removes a like' do
      post "/v1/products/#{product.uuid}/like", nil, 'X-Authenticated-Userid' => user.uuid
      post "/v1/products/#{product.uuid}/unlike", nil, 'X-Authenticated-Userid' => user.uuid
      expect(response.status).to eq(204)
      expect(product.get_likes.count).to eq(0)
    end

    it 'fetches likes' do
      post "/v1/products/#{product.uuid}/like", nil, 'X-Authenticated-Userid' => user.uuid
      get "/v1/products/#{product.uuid}/relationships/likes", params, 'X-Authenticated-Userid' => user.uuid
      likes = json['data']
      expect(likes.count).to eq(1)
    end
  end
end
