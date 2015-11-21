require 'rails_helper'

RSpec.describe Users::Unfollow, type: :model do
  describe ".call" do

    let(:follower) { create(:user) }
    let(:followed) { create(:user) }

    it "raises an error when trying to follow itself" do
      expect do
        described_class.call(follower_id: follower.uuid, followed_id: follower.uuid)
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

    it "unfollows an user", :truncate do
      Users::Follow.call(follower_id: follower.uuid, followed_id: followed.uuid)
      expect(follower.following.count).to eq(1)
      described_class.call(follower_id: follower.uuid, followed_id: followed.uuid)
      expect(follower.following.count).to eq(0)
      expect(follower.following?(followed)).to eq(false)
      expect(follower.following.map(&:uuid)).to eq([])
      # Inverse also holds.
      expect(followed.followers.count).to eq(0)
      expect(followed.followers.map(&:uuid)).to eq([])
    end
  end
end
