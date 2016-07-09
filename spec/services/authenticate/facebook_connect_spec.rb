require "rails_helper"

RSpec.describe Authenticate::FacebookConnect, type: :model do

  # To re-run these tests and save the cassettes, remember to have kong
  # properly setup in the tests env:
  # export DOCKER_HOST_IP=127.0.0.1
  # eval "$(bundle exec rake kong:setup)"

  let(:fb_token) do
    'EAACEdEose0cBAOyptxp0nMIx2GVcD3KDzEZCZB4ZCiTpsB4XuKKWqZCeZBB9Ps4l3cIrt3bmPq0aXZCiWJhmtMmPlZBxmiUn7TmHXr8NeKh6NkhCc7aBqu4EMjZAonGaqd52o4KMZBmYkYNbBg12kSE6HXSo6vHZCv1CPJNYG2JAniIgZDZD'
  end

  describe '.call', vcr: true do
    it 'raises error when token is invalid' do
      expect do
        described_class.call(token: 'invalid', expires_in: 1)
      end.to raise_error(ApiError::Unauthorized)
    end

    it 'creates user when token is valid' do
      expect do
        described_class.call(token: fb_token, expires_in: 1)
      end.to change(User, :count).by(1)
      fb_profile = Koala::Facebook::API.new(fb_token).get_object('me')
      user = User.last
      expect(user.email).to eq(fb_profile['email'])
      expect(user.facebook_account.uuid).to eq(fb_profile['id'].to_s)
    end

    it 'returns existent user when fb email is already in the db' do
      existent_user = create(:user, email: 'rafaelchacon@gmail.com')
      expect do
        described_class.call(token: fb_token, expires_in: 1)
      end.to change(User, :count).by(0)
      fb_account = FacebookAccount.last
      expect(fb_account.user).to eq(existent_user)
    end

    it 'returns existent user when fb account is already in the db' do
      fb_profile = Koala::Facebook::API.new(fb_token).get_object('me')
      existent_user = create(:user)
      FacebookAccount.create(user_id: existent_user.uuid,
                             token: fb_token,
                             expires_in: 100,
                             uuid: fb_profile['id'])
      outcome = nil
      expect do
        outcome = described_class.call(token: fb_token, expires_in: 1)
      end.to change(User, :count).by(0)
      expect(outcome.success_result[:user_id]).to eq(existent_user.uuid)
    end
  end
end
