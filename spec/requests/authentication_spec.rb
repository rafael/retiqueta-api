require 'rails_helper'

RSpec.describe 'User authentication', type: :request do
  let(:user) { create(:user, password: '123456') }
  let(:fb_token) do
    'EAACEdEose0cBAEn932kZAW9DZBVJRSpW3yN71YsNfZAL5uuekUUN9JAZC2lWCkv6bxfVq3SNXwPrmJKP5cudu0HmfRXow65RvXRmTTIOI9PhCOclvYTYt32hRe57bILfqwRsNPIMBVRBmxuqNMMwP9UEnN8VItUD2RQSSyOK4AZDZD'
  end

  it 'validates presence of login' do
    post '/v1/authenticate'
    failed_error = ApiError::FailedValidation.new("Login #{I18n.t('errors.messages.blank')}")
    expect(json).to have_error_json_as(failed_error)
    expect(response.status).to eq(failed_error.status)
  end

  it 'validates presence of password' do
    post '/v1/authenticate', login: 'test'
    failed_error = ApiError::FailedValidation.new("Password #{I18n.t('errors.messages.blank')}")
    expect(json).to have_error_json_as(failed_error)
    expect(response.status).to eq(failed_error.status)
  end

  it 'validates presence of client_id' do
    post '/v1/authenticate', login: 'test', password: 'test'
    failed_error = ApiError::FailedValidation.new("Client #{I18n.t('errors.messages.blank')}")
    expect(json).to have_error_json_as(failed_error)
    expect(response.status).to eq(failed_error.status)
  end

  it 'authenticates an user with username', :vcr do
    post '/v1/authenticate', login: user.username, password: '123456', client_id: 'ret-mobile-ios'
    expect(response.status).to eq(200)
    expect(json.keys).to eq(%w(refresh_token token_type access_token expires_in user_id))
    expect(json['user_id']).to eq(user.uuid)
  end

  it 'authenticates an user with email', vcr: true do
    post '/v1/authenticate', login: user.email, password: '123456', client_id: 'ret-mobile-ios'
    expect(response.status).to eq(200)
    expect(json.keys).to eq(%w(refresh_token token_type access_token expires_in user_id))
    expect(json['user_id']).to eq(user.uuid)
  end

  it 'gives error when the password is invalid' do
    post '/v1/authenticate', login: user.email, password: '1234567', client_id: 'ret-mobile-ios'
    unauthorized_error = ApiError::Unauthorized.new(I18n.t('user.errors.invalid_password'))
    expect(response.status).to eq(unauthorized_error.status)
    expect(json).to have_error_json_as(unauthorized_error)
  end

  it "gives error when the user doesn't exist" do
    post '/v1/authenticate', login: 'invalid', password: '1234567', client_id: 'ret-mobile-ios'
    error = ApiError::NotFound.new(I18n.t('user.errors.invalid_username'))
    expect(response.status).to eq(error.status)
    expect(json).to have_error_json_as(error)
  end

  it 'refreshes a token', :vcr do
    post '/v1/authenticate', login: user.email, password: '123456', client_id: 'ret-mobile-ios'
    expect(response.status).to eq(200)
    token = json['refresh_token']
    post '/v1/authenticate/token', refresh_token: token, client_id: 'ret-mobile-ios'
    expect(response.status).to eq(200)
    expect(json.keys).to eq(%w(refresh_token token_type access_token expires_in))
  end

  it 'gives an error when token is missing' do
    post '/v1/authenticate/token'
    failed_error = ApiError::FailedValidation.new("Refresh token #{I18n.t('errors.messages.blank')}")
    expect(response.status).to eq(failed_error.status)
    expect(json).to have_error_json_as(failed_error)
  end

  it 'authenticates with a facebook token', vcr: true do
    post '/v1/authenticate/fb/connect', token: fb_token, expires_in: '123456', client_id: 'ret-mobile-ios'
    expect(response.status).to eq(200)
  end
end
