require 'rails_helper'

RSpec.describe Products::CreateComment, type: :model do
  describe ".call" do
    let(:user) { create(:user) }
    let(:product) { create(:product) }
    let(:params) {
      {
        user_id: user.uuid,
        product_id: product.uuid,
        data: {
          type: "text_comments",
          attributes: {
            text: "Hey I like your shoes @rafael"
          }
        }
      }
    }

    it "adds a comment to the product" do
      service_result = described_class.call(params)
      expect(service_result.success_result).to eq(Comment.last)
      comment = service_result.success_result
      expect(comment.user).to eq(user)
      expect(comment.user_pic).to eq(user.pic.url(:small))
      expect(comment.data).to eq(params[:data].to_json)
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
