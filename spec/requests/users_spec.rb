require 'rails_helper'

RSpec.describe "Users", type: :request do

  let(:user) { create(:user, password: '123456') }

  let(:update_params) do
    {
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
  end

  it "fetches an user by uuid" do
    get "/v1/users/#{user.uuid}", nil, { 'X-Authenticated-Userid' => user.uuid }
    expect(response.status).to eq(200)
    user = User.last
    expect(json["data"]).to_not be_nil
    expect(json["data"]["id"]).to eq(user.uuid)
    expect(json["data"]["type"]).to eq("users")
    user_response_attributes = json["data"]["attributes"]
    expect(user_response_attributes.keys.to_set).to eq(["email",
                                                        "username",
                                                        "first_name",
                                                        "last_name",
                                                        "profile_pic",
                                                        "website",
                                                        "country",
                                                        "bio"].to_set)
    expect(user_response_attributes["email"]).to eq(user.email)
    expect(user_response_attributes["username"]).to eq(user.username)
    expect(user_response_attributes["first_name"]).to eq(user.first_name)
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

  context "relationships" do
    it "returns user products" do
      create(:product, title: "zapato super #nike", user: user)
      create(:product, title: "camisa zara", user: user)
      get "/v1/users/#{user.uuid}/relationships/products", nil, { 'X-Authenticated-Userid' => "any" }
      expect(response.status).to eq(200)
      expect(json['data'].count).to eq(2)
    end

    it "includes pictures when requested" do
      create(:product, title: "zapato super #nike", user: user)
      create(:product, title: "camisa zara", user: user)
      get "/v1/users/#{user.uuid}/relationships/products", { include: 'product_pictures' }, { 'X-Authenticated-Userid' => "any" }
      expect(response.status).to eq(200)
      expect(json['data'].count).to eq(2)
      expect(json['included'].count).to eq(2)
    end
  end
end
