require 'rails_helper'

RSpec.describe Products::Like, type: :model do
  describe ".call" do
    let(:user) { create(:user) }
    let(:product) { create(:product) }
    let(:params) {
      {
        user_id: user.uuid,
        product_id: product.uuid,
      }
    }

    it "adds a like to the product" do
      described_class.call(params)
      expect(product.get_likes.count).to eq(1)
      expect(user.liked?(product)).to eq(true)
    end

    it "gives proper error when user_id is invalid" do
      expect do
        described_class.call(params.merge(user_id: "invalid"))
      end.to raise_error(ApiError::NotFound, "User not found")
    end

    it "gives proper error when product_id is invalid" do
      expect do
        described_class.call(params.merge(product_id: "invalid"))
      end.to raise_error(ApiError::NotFound, "Product not found")
    end
  end
end
