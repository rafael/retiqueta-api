require 'rails_helper'

RSpec.describe 'User authentication', type: :request do
  let(:user) { create(:user, password: '123456') }
  let(:fb_token) do
    'EAACEdEose0cBAOyptxp0nMIx2GVcD3KDzEZCZB4ZCiTpsB4XuKKWqZCeZBB9Ps4l3cIrt3bmPq0aXZCiWJhmtMmPlZBxmiUn7TmHXr8NeKh6NkhCc7aBqu4EMjZAonGaqd52o4KMZBmYkYNbBg12kSE6HXSo6vHZCv1CPJNYG2JAniIgZDZD'
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

  it 'authenticates with jwt token from ionic' do
    Rails.application.secrets.ionic_jwt_secret = 'secret'
    payload = { data: { username: user.email, password: '123456' } }
    token = JWT.encode(payload, 'secret', 'HS256')
    redirect_uri = 'http://dummy.com/ionic/success'
    get '/v1/authenticate/ionic/authorize',
        token: token,
        state: 'test_state',
        redirect_uri: redirect_uri
    expect(response.status).to eq(302)
    expected_token = JWT.encode({ user_id: user.uuid }, 'secret', 'HS256')
    expected_location = "#{redirect_uri}?state=test_state&token=#{expected_token}"
    expect(response.location).to eq(expected_location)
  end

  it 'does not authenticates with jwt token from ionic when password is invalid' do
    Rails.application.secrets.ionic_jwt_secret = 'secret'
    payload = { data: { username: user.email, password: 'invalid' } }
    token = JWT.encode(payload, 'secret', 'HS256')
    redirect_uri = 'http://dummy.com/ionic/success'
    get '/v1/authenticate/ionic/authorize',
        token: token,
        state: 'test_state',
        redirect_uri: redirect_uri
    expect(response.status).to eq(401)
  end

  it 'does not authenticates with jwt token from ionic when signature is invalid' do
    Rails.application.secrets.ionic_jwt_secret = 'secret'
    payload = { data: { username: user.email, password: '123456' } }
    token = JWT.encode(payload, 'secret2', 'HS256')
    redirect_uri = 'http://dummy.com/ionic/success'
    get '/v1/authenticate/ionic/authorize',
        token: token,
        state: 'test_state',
        redirect_uri: redirect_uri
    expect(response.status).to eq(401)
  end
end
