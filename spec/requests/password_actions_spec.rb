require 'rails_helper'
require 'token_generator'

RSpec.describe "PasswordActions", type: :request do
  let!(:user) do
    create(
      :user,
      email: email,
      password_reset_token: token_enc,
      password_reset_sent_at: DateTime.now.utc)
  end

  let(:email) { "john@gmail.com" }
  let(:token_raw) { "token_raw" }
  let(:token_enc) { TokenGenerator.new(User, :password_reset_token).digest(token_raw) }

  describe "create" do
    let(:payload) do
      {
        data: {
          type: "users",
          attributes: {
            email: email
          }
        }
      }
    end

    it "responds with 204 No Content" do
      post "/v1/send_password_reset", payload
      expect(response.status).to eq(204)
      expect(response.body).to be_empty
    end

    it "relies on PasswordActions::SendReset service object to handle request" do
      expect(PasswordActions::SendReset).to receive(:call).with(payload)
      post "/v1/send_password_reset", payload
    end
  end

  describe "update" do
    let(:payload) do
      {
        data: {
          type: "users",
          attributes: {
            password: "password",
            token: token_raw
          }
        }
      }
    end

    it "responds with 204 No Content" do
      post "/v1/reset_password", payload
      expect(response.status).to eq(204)
      expect(response.body).to be_empty
    end

    it "relies on PasswordActions::Reset service object to handle request" do
      expect(PasswordActions::Reset).to receive(:call).with(payload)
      post "/v1/reset_password", payload
    end
  end
end
