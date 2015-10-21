require 'rails_helper'

RSpec.describe "Users", type: :request do

  let(:user) { create(:user, password: '123456') }

  it "fetches an user by uuid" do
    get "/v1/users/#{user.uuid}"
    expect(response.status).to eq(200)
    user = User.last
    expect(json["data"]).to_not be_nil
    expect(json["data"]["id"]).to eq(user.uuid)
    expect(json["data"]["type"]).to eq("users")
    user_response_attributes = json["data"]["attributes"]
    expect(user_response_attributes["name"]).to eq(user.name)
    expect(user_response_attributes["email"]).to eq(user.email)
    expect(user_response_attributes["username"]).to eq(user.username)
  end

  it "responds with valid json on errors" do
    get "/v1/users/invalid_id"
    failed_error = ApiError::NotFound.new(I18n.t("user.errors.not_found"))
    expect(response.status).to eq(failed_error.status)
    expect(json).to have_error_json_as(failed_error)
  end
end
