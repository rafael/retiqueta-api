require 'rails_helper'

RSpec.describe "User authenticasion", type: :request do
  let(:user) { create(:user, password: '123456') }

  it "authenticates an user with valid email and password" do

    post "/authentication", login: user.username, password: '123456'
    expect(response.status).to eq(201)
  end
end
