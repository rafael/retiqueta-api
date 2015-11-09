require 'rails_helper'

RSpec.describe "Products", type: :request do

  let(:user) { create(:user, password: '123456') }

  let(:valid_product_picture) do
    {
      data: {
        type: "product_pictures",
        attributes: {
          position: 0,
          pic: {
            content_type: "image/jpeg",
            filename: "watchmen.jpg",
            content: Base64.encode64(File.open(Rails.root.join("spec/fixtures/watchmen.jpg")) { |io| io.read })
          },
        }
      }
    }
  end

  let(:params) do
    {
      user_id: user.uuid,
      data: {
        type: "products",
        attributes: {
          category: "shoes",
          title: "My awesome shoes",
          description: "Estos zapatos tienen mucha historia conmigo",
          original_price: 60,
          price: 40,
          pictures: nil
        }
      }
    }
  end

  it "creates a product" do
    VCR.use_cassette('product/uploading_pic', match_requests_on: [:host, :method]) do
      post "/v1/product_pictures", valid_product_picture, { 'X-Authenticated-Userid' => user.uuid }
    end
    expect(response.status).to eq(201)
    picture_id = json["data"]["id"]
    params[:data][:attributes].merge!(pictures: [picture_id])
    post "/v1/products", params, { 'X-Authenticated-Userid' => user.uuid }
    expect(response.status).to eq(201)
  end

  it "product index only returns featured products" do
    product = create(:product, title: "zapato super #nike", featured: true)
    create(:product, title: "zapato super #nike")
    get "/v1/products"
    expect(response.status).to eq(200)
    expect(json['data'].count).to eq(1)
    expect(json['data'].first['id']).to eq(product.uuid)
  end

  it "product index can be paginated" do
    4.times do |time|
      create(:product, title: "zapato super #{time} #nike", featured: true)
    end
    get "/v1/products", page: { number: 1, size: 1 }
    expect(response.status).to eq(200)
    expect(json['data'].count).to eq(1)
    expect(json['links']).to_not be_empty
  end

  context "search" do
    it "searches a product" do
      product = create(:product, title: "zapato super #nike")
      expect(Product).to receive(:search).and_return([product])
      get "/v1/products/search", q: "nike"
      expect(response.status).to eq(200)
      expect(json['data'].first['id']).to eq(product.uuid)
    end

    it "searches a product and ignores include when invalid" do
      product = create(:product, title: "zapato super #nike")
      expect(Product).to receive(:search).and_return([product])
      get "/v1/products/search", q: "nike", include: 'product_picturexs'
      expect(response.status).to eq(200)
      expect(json['data'].first['id']).to eq(product.uuid)
      expect(json['included']).to be_nil
    end

    it "searches a product and includes pictures when requested" do
      product = create(:product, title: "zapato super #nike")
      expect(Product).to receive(:search).and_return([product])
      get "/v1/products/search", q: "nike", include: 'product_pictures'
      expect(response.status).to eq(200)
      expect(json['data'].first['id']).to eq(product.uuid)
      expect(json['included'].count).to eq(1)
    end
  end
end
