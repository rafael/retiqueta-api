require 'rails_helper'

RSpec.describe "Products", type: :request do

  let(:user) { create(:user, password: '123456') }

  let(:valid_product_picture) {
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
  }

  let(:params) {
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
  }

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
end
