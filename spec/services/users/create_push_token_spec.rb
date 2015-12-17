require 'rails_helper'

RSpec.describe Users::CreatePushToken, type: :model do
  describe ".call" do

    let(:user) { create(:user) }
    let(:params) {
      {
        user_id: user.uuid,
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
    }

    it "user needs to exist" do
      expect do
        described_class.call(user_id: "not-valid")
      end.to raise_error(ApiError::NotFound, "User not found")
    end

    it "create a push notification token" do
      described_class.call(params)
      expect(user.reload.push_tokens.count).to eq(1)
      push_token = user.reload.push_tokens.last
      expect(push_token.environment).to eq('development')
      expect(push_token.token).to eq('super-token')
      expect(push_token.device_id).to eq('device-id')
      expect(push_token.platform).to eq('ios')
    end
  end
end
