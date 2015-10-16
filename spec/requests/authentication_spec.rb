require 'rails_helper'

RSpec.describe "User authentication", type: :request do
  let(:user) { create(:user, password: '123456') }

  it "authenticates an user with username", :vcr do
    post "/v1/authenticate", login: user.username, password: '123456', client_id: 'ret-mobile-ios'
    expect(response.status).to eq(200)
    expect(json.keys).to eq(["refresh_token", "token_type", "access_token", "expires_in"])
  end

  it "authenticates an user with email", :vcr do
    post "/v1/authenticate", login: user.email, password: '123456', client_id: 'ret-mobile-ios'
    expect(response.status).to eq(200)
    expect(json.keys).to eq(["refresh_token", "token_type", "access_token", "expires_in"])
  end

  it "gives error when the password is invalid" do
    post "/v1/authenticate", login: user.email, password: '1234567', client_id: 'ret-mobile-ios'
    expect(response.status).to eq(401)
    expect(json).to eq({
                         "code" => ApiError::FAILED_VALIDATION,
                         "title" =>  ApiError.title_for_error(ApiError::FAILED_VALIDATION),
                         "detail" => "Invalid username or password"
                       })
  end

  it "refreshes a token", :vcr do
    post "/v1/authenticate", login: user.email, password: '123456', client_id: 'ret-mobile-ios'
    expect(response.status).to eq(200)
    token = json["refresh_token"]
    post "/v1/authenticate/token", refresh_token: token, client_id: 'ret-mobile-ios'
    expect(response.status).to eq(200)
    expect(json.keys).to eq(["refresh_token", "token_type", "access_token", "expires_in"])
  end

  it "gives an error when token is missing" do
    post "/v1/authenticate/token"
    expect(response.status).to eq(400)
    expect(json).to eq({
                         "code" => ApiError::FAILED_VALIDATION,
                         "title" =>  ApiError.title_for_error(ApiError::FAILED_VALIDATION),
                         "detail" => "Refresh token can't be blank, Client can't be blank"
                       })
  end
end
