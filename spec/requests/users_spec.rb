require 'rails_helper'

RSpec.describe "Users", type: :request do

  let(:user) { create(:user, password: '123456') }

  let(:update_params) {
    {
      id: user.uuid,
      data: {
        type: "users",
        attributes: {
          website: 'http://www.google.com',
          first_name: 'Juanito',
          last_name: 'Alimana',
          bio: 'My super biografia',
          country: 'venezuela',
        }
      }
    }
  }

  it "fetches an user by uuid" do
    get "/v1/users/#{user.uuid}", nil, { 'X-Authenticated-Userid' => user.uuid }
    expect(response.status).to eq(200)
    user = User.last
    expect(json["data"]).to_not be_nil
    expect(json["data"]["id"]).to eq(user.uuid)
    expect(json["data"]["type"]).to eq("users")
    user_response_attributes = json["data"]["attributes"]
    expect(user_response_attributes["email"]).to eq(user.email)
    expect(user_response_attributes["username"]).to eq(user.username)
  end

  it "updates user website, first_name, last_name, bio, country" do
    patch "/v1/users/#{user.uuid}", update_params, { 'X-Authenticated-Userid' => user.uuid }
    expect(response.status).to eq(204)
    user = User.last
    expect(user.first_name).to eq('Juanito')
    expect(user.last_name).to eq('Alimana')
    expect(user.bio).to eq('My super biografia')
    expect(user.country).to eq('venezuela')
  end

  it "doesn't allow user to see other users profile" do
    user_2 = create(:user, password: '123456')
    get "/v1/users/#{user_2.uuid}", nil, { 'X-Authenticated-Userid' => user.uuid }
    failed_error = ApiError::Unauthorized.new(I18n.t("errors.messages.unauthorized"))
    expect(response.status).to eq(failed_error.status)
    expect(json).to have_error_json_as(failed_error)
  end

  it "responds with valid json on errors" do
    get "/v1/users/invalid_id", nil, { 'X-Authenticated-Userid' => "invalid_id" }
    failed_error = ApiError::NotFound.new(I18n.t("user.errors.not_found"))
    expect(response.status).to eq(failed_error.status)
    expect(json).to have_error_json_as(failed_error)
  end
end
