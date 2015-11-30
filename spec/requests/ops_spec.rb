require 'rails_helper'

RSpec.describe "OpsSpec", type: :request do

  let(:payload) {
    {
      data: {
        type: "product_pictures",
        attributes: {
          pic: {
            content_type: "image/jpeg",
            filename: "watchmen.jpg",
          }
        }
      }
    }
  }

  it "saves an ionic request" do
    post '/e22e9a38-cd10-4132-b2d3-a845b0aa0539', payload
    expect(response.status).to eq(200)
    request = IonicWebhookCallback.last
    expect(request.payload).to eq(payload.to_json)
  end
end
