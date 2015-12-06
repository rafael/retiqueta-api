require 'rails_helper'

RSpec.describe "Users", type: :request do

  let(:user) { create(:user, password: '123456') }
  let(:followed) { create(:user, password: '123456') }
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
                                                        "bio",
                                                        "following_count",
                                                        "followers_count"].to_set)
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

  it "uses a different serializer when another user is seeing the profile" do
    user_2 = create(:user, password: '123456')
    get "/v1/users/#{user_2.uuid}", nil, { 'X-Authenticated-Userid' => user.uuid }
    expect(response.status).to eq(200)
    user_response_attributes = json["data"]["attributes"]
    expect(user_response_attributes.keys.to_set).to eq(["username",
                                                        "first_name",
                                                        "last_name",
                                                        "profile_pic",
                                                        "website",
                                                        "country",
                                                        "bio",
                                                        "following_count",
                                                        "followers_count"].to_set)
  end

  it "responds with valid json on errors" do
    get "/v1/users/invalid_id", nil, { 'X-Authenticated-Userid' => "invalid_id" }
    failed_error = ApiError::NotFound.new(I18n.t("user.errors.not_found"))
    expect(response.status).to eq(failed_error.status)
    expect(json).to have_error_json_as(failed_error)
  end

  context "social networking" do

    it "can follow an user" do
      post "/v1/users/#{followed.uuid}/follow", nil, { 'X-Authenticated-Userid' => user.uuid }
      expect(response.status).to eq(204)
      expect(user.following.count).to eq(1)
    end

    it "can unfollow an user" do
      post "/v1/users/#{followed.uuid}/follow", nil, { 'X-Authenticated-Userid' => user.uuid }
      post "/v1/users/#{followed.uuid}/unfollow", nil, { 'X-Authenticated-Userid' => user.uuid }
      expect(user.following.count).to eq(0)
      expect(response.status).to eq(204)
    end

    it "returns proper metadata when visiting followed user profile" do
      post "/v1/users/#{followed.uuid}/follow", nil, { 'X-Authenticated-Userid' => user.uuid }
      get "/v1/users/#{followed.uuid}", nil, { 'X-Authenticated-Userid' => user.uuid }
      expect(response.status).to eq(200)
      expect(json["meta"]["followed_by_current_user"]).to eq(true)
    end
  end

  context "relationships" do
    it "returns user products" do
      create(:product, title: "zapato super #nike", user: user)
      create(:product, title: "camisa zara", user: user)
      get "/v1/users/#{user.uuid}/relationships/products", nil, { 'X-Authenticated-Userid' => "any" }
      expect(response.status).to eq(200)
      expect(json['data'].count).to eq(2)
    end

    it "user products can be paginated" do
      create(:product, title: "zapato super #nike", user: user)
      create(:product, title: "camisa zara", user: user)
      get "/v1/users/#{user.uuid}/relationships/products", { page: { size: 1, number: 1 } }, { 'X-Authenticated-Userid' => "any" }
      expect(response.status).to eq(200)
      expect(json['data'].count).to eq(1)
      expect(json['links']).to_not be_empty
    end

    it "includes pictures when requested" do
      create(:product, title: "zapato super #nike", user: user)
      create(:product, title: "camisa zara", user: user)
      get "/v1/users/#{user.uuid}/relationships/products", { include: 'product_pictures' }, { 'X-Authenticated-Userid' => "any" }
      expect(response.status).to eq(200)
      expect(json['data'].count).to eq(2)
      expect(json['included'].count).to eq(2)
    end

    it "returns user followers" do
      post "/v1/users/#{followed.uuid}/follow", nil, { 'X-Authenticated-Userid' => user.uuid }
      get "/v1/users/#{followed.uuid}/relationships/followers", {}, { 'X-Authenticated-Userid' => user.uuid }
      expect(response.status).to eq(200)
      expect(json['data'].count).to eq(1)
      expect(json['data'].first['id']).to eq(user.uuid)
      expect(json['data'].first['meta']).to eq({ 'followed_by_current_user' => false })
      expect(json['data'].first['attributes'].keys.to_set).to eq(['username'].to_set)
    end

    it "returns user followers in a paginated way" do
      follower_2 = create(:user, password: '123456')
      post "/v1/users/#{followed.uuid}/follow", nil, { 'X-Authenticated-Userid' => user.uuid }
      post "/v1/users/#{followed.uuid}/follow", nil, { 'X-Authenticated-Userid' => follower_2.uuid }
      get "/v1/users/#{followed.uuid}/relationships/followers", { page: { size: 1, number: 1 } }, { 'X-Authenticated-Userid' => user.uuid }
      expect(response.status).to eq(200)
      expect(json['data'].count).to eq(1)
      expect(json['links'].keys).to eq(["self", "next", "last"])
    end

    it "returns user following" do
      post "/v1/users/#{followed.uuid}/follow", nil, { 'X-Authenticated-Userid' => user.uuid }
      get "/v1/users/#{user.uuid}/relationships/following", {}, { 'X-Authenticated-Userid' => user.uuid }
      expect(response.status).to eq(200)
      expect(json['data'].count).to eq(1)
      expect(json['data'].first['id']).to eq(followed.uuid)
      expect(json['data'].first['meta']).to eq({ 'followed_by_current_user' => true })
      expect(json['data'].first['attributes'].keys.to_set).to eq(['username'].to_set)
    end

    it "returns user following with pagination" do
      followed_2 = create(:user, password: '123456')
      post "/v1/users/#{followed.uuid}/follow", nil, { 'X-Authenticated-Userid' => user.uuid }
      post "/v1/users/#{followed_2.uuid}/follow", nil, { 'X-Authenticated-Userid' => user.uuid }
      get "/v1/users/#{user.uuid}/relationships/following", { page: { size: 1, number: 1 } }, { 'X-Authenticated-Userid' => user.uuid }
      expect(response.status).to eq(200)
      expect(json['data'].count).to eq(1)
      expect(json['links'].keys).to eq(["self", "next", "last"])
    end

    it "creates a push token" do
      params =
        {
          data: {
            type: "push_notifications",
            attributes: {
              environment: 'development',
              token: 'super-token',
              device_id: 'device-id',
              platform: 'ios',
            }
          }
        }

      post "/v1/users/#{user.uuid}/relationships/push_tokens", params, { 'X-Authenticated-Userid' => user.uuid }
      expect(response.status).to eq(204)
    end
  end
end
