require 'rails_helper'

RSpec.describe "User authenticasion", type: :request do
  let(:user) { create(:user, password: '123456') }

  it "authenticates an user with username", :vcr do
    post "/v1/authenticate", login: user.username, password: '123456'
    expect(response.status).to eq(200)
    expect(json.keys).to eq(["refresh_token", "token_type", "access_token", "expires_in"])
  end

  it "authenticates an user with email", :vcr do
    post "/v1/authenticate", login: user.email, password: '123456'
    expect(response.status).to eq(200)
    expect(json.keys).to eq(["refresh_token", "token_type", "access_token", "expires_in"])
  end

  it "gives error when the password is invalid" do
    post "/v1/authenticate", login: user.email, password: '1234567'
    expect(response.status).to eq(401)
    expect(json).to eq({
                         "code" => ApiError::FAILED_VALIDATION,
                         "title" =>  ApiError.title_for_error(ApiError::FAILED_VALIDATION),
                         "detail" => "Invalid username or password"
                       })
  end
end
