require 'rails_helper'

RSpec.describe Users::Follow, type: :model do
  describe ".call" do

    let(:follower) { create(:user) }
    let(:followed) { create(:user) }

    it "raises an error when trying to follow itself" do
      expect do
        described_class..call(follower_id: follower.uuid, followed_id: follower.uuid)
      end.to raise_error(ApiError::FailedValidation, "You can't follow yourself")
    end

    it "followed needs to exist" do
      expect do
        described_class.call(follower_id: follower.uuid, followed_id: "not-valid")
      end.to raise_error(ApiError::NotFound, "User not found")
    end

    it "follower needs to exist" do
      expect do
        described_class.call(follower_id: "invalid", followed_id: followed.uuid)
      end.to raise_error(ApiError::NotFound, "User not found")
    end

    it "follows an user", :truncate do
      described_class.call(follower_id: follower.uuid, followed_id: followed.uuid)
      expect(follower.following.count).to eq(1)
      expect(follower.following?(followed)).to eq(true)
      expect(follower.following.map(&:uuid)).to eq([followed.uuid])
      # Inverse also holds.
      expect(followed.followers.count).to eq(1)
      expect(followed.followers.map(&:uuid)).to eq([follower.uuid])
    end

    it "raises exception when following an user twice", :truncate do
      described_class.call(follower_id: follower.uuid, followed_id: followed.uuid)
      expect do
        described_class.call(follower_id: follower.uuid, followed_id: followed.uuid)
      end.to raise_error(ApiError::FailedValidation, "You can't follow an user twice")
    end
  end
end
