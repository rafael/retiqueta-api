require 'rails_helper'

RSpec.describe Users::CreatePushToken, type: :model do
  describe '.call' do
    let(:user) { create(:user) }
    let(:user_2) { create(:user) }
    let(:params) do
      {
        user_id: user.uuid,
        data: {
          type: 'push_notifications',
          attributes: {
            environment: 'development',
            token: 'super-token',
            device_id: 'device-id',
            platform: 'ios'
          }
        }
      }
    end

    it 'user needs to exist' do
      expect do
        described_class.call(user_id: 'not-valid')
      end.to raise_error(ApiError::NotFound, 'User not found')
    end

    it 'create a push notification token' do
      described_class.call(params)
      expect(user.reload.push_tokens.count).to eq(1)
      push_token = user.reload.push_tokens.last
      expect(push_token.environment).to eq('development')
      expect(push_token.token).to eq('super-token')
      expect(push_token.device_id).to eq('device-id')
      expect(push_token.platform).to eq('ios')
      expect(push_token.uuid).to_not be_nil
      expect(push_token.id).to_not be_nil
    end

    it 'upserst a push token for the same token' do
      the_params = params
      described_class.call(the_params)
      expect(user.reload.push_tokens.count).to eq(1)
      the_params[:data][:attributes][:device_id] = 'newdevice'
      described_class.call(the_params)
      expect(user.reload.push_tokens.count).to eq(1)
      push_token = user.reload.push_tokens.last
      expect(push_token.environment).to eq('development')
      expect(push_token.token).to eq('super-token')
      expect(push_token.device_id).to eq('newdevice')
      expect(push_token.platform).to eq('ios')
      expect(push_token.uuid).to_not be_nil
      expect(push_token.id).to_not be_nil
    end

    it 'when upserting, a token should be transferred to a new user' do
      the_params = params
      described_class.call(the_params)
      expect(user.reload.push_tokens.count).to eq(1)
      the_params[:data][:attributes][:device_id] = 'newdevice'
      the_params[:user_id] = user_2.uuid
      described_class.call(the_params)
      expect(user.reload.push_tokens.count).to eq(0)
      expect(user_2.reload.push_tokens.count).to eq(1)
      push_token = user_2.reload.push_tokens.last
      expect(push_token.environment).to eq('development')
      expect(push_token.token).to eq('super-token')
      expect(push_token.device_id).to eq('newdevice')
      expect(push_token.platform).to eq('ios')
      expect(push_token.uuid).to_not be_nil
      expect(push_token.id).to_not be_nil
    end
  end
end
