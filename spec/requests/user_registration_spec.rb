require 'rails_helper'

RSpec.describe "User Registration", type: :request do
  let(:params) {
    {
      data: {
        type: "users",
        attributes: {
          password: "123456",
          email: "rafaelchacon@gmail.com",
          username: "rafael"
        }
      }
    }
  }

  it "creates an user and responds with valid json" do
    post "/v1/registrations", params
    expect(response.status).to eq(201)
    user = User.last
    expect(json["data"]).to_not be_nil
    expect(json["data"]["id"]).to eq(user.uuid)
    expect(json["data"]["type"]).to eq("users")
    user_response_attributes = json["data"]["attributes"]
    expect(user_response_attributes["email"]).to eq("rafaelchacon@gmail.com")
    expect(user_response_attributes["username"]).to eq("rafael")
  end

  it "responds with valid json on errors" do
    params[:data][:attributes].delete(:password)
    post "/v1/registrations", params
    failed_error = ApiError::FailedValidation.new("Password #{I18n.t("errors.messages.blank")}")
    expect(response.status).to eq(failed_error.status)
    expect(json["data"]).to be_nil
    expect(json).to have_error_json_as(failed_error)
  end
end
