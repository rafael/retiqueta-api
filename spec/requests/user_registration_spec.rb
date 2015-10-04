require 'spec_helper'

RSpec.describe "User Registration", type: :request do

  it "creates an user and responds with valid json" do
    params = {
      data: {
        type: "users",
        attributes: {
          name: "Rafael Chacon",
          password: "123456",
          email: "rafaelchacon@gmail.com",
          username: "rafael"
        }
      }
    }
    post "/v1/registrations", params
    expect(response.status).to eq(201)
    user = User.last
    expect(json["data"]).to_not be_nil
    expect(json["data"]["id"]).to eq(user.uuid)
    expect(json["data"]["type"]).to eq("users")
    user_response_attributes = json["data"]["attributes"]
    expect(user_response_attributes["name"]).to eq("Rafael Chacon")
    expect(user_response_attributes["email"]).to eq("rafaelchacon@gmail.com")
    expect(user_response_attributes["username"]).to eq("rafael")
  end

  it "responds with valid json on errors" do
    params = {
      data: {
        type: "users",
        attributes: {
          password: "123456",
          email: "rafaelchacon@gmail.com",
          username: "rafael"
        }
      }
    }
    post "/v1/registrations", params
    expect(response.status).to eq(422)
    expect(json["data"]).to be_nil
    expect(json).to eq("")
  end
end
