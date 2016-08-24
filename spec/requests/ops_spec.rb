require 'rails_helper'

RSpec.describe 'OpsSpec', type: :request do
  let(:payload) do
    {
      data: {
        type: 'product_pictures',
        attributes: {
          pic: {
            content_type: 'image/jpeg',
            filename: 'watchmen.jpg'
          }
        }
      }
    }
  end

  let(:product) { create(:product) }
  let(:user) { create(:user) }
  let(:mandrill_payload) do
    {
      mandrill_events: [
        {
          msg: {
            text: 'Test comment',
            email: "producto+#{product.uuid}",
            from_email: user.email
          }
        }
      ].to_json
    }
  end

  it 'saves an ionic request' do
    post '/e22e9a38-cd10-4132-b2d3-a845b0aa0539', payload
    expect(response.status).to eq(200)
    request = IonicWebhookCallback.last
    expect(request.payload).to eq(payload.to_json)
  end

  it 'saves a comment via email' do
    post '/8e6fd49b-8d40-4741-88d0-0633e3568cac', mandrill_payload
    expect(response.status).to eq(200)
    comment = Comment.last
    expect(comment).to_not be_nil
    expect(comment.user).to eq(user)
  end
end
