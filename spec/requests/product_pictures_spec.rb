require 'rails_helper'

RSpec.describe "ProductPicture", type: :request do

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

  it "Uploads a product picture" do
    VCR.use_cassette('product/uploading_pic', match_requests_on: [:host, :method]) do
      post "/v1/product_pictures", valid_product_picture, { 'X-Authenticated-Userid' => user.uuid }
    end
    expect(response.status).to eq(201)
    product_pic = ProductPicture.last
    expect(json["data"]["id"]).to eq(product_pic.id.to_s)
    expect(json["data"]["attributes"]["url"]).to eq(product_pic.pic.url)
  end
end
