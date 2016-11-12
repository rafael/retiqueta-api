require 'rails_helper'

RSpec.describe Products::Create, type: :model do

  include ActiveJob::TestHelper

  describe ".call" do
    let(:user) { create(:user) }
    let(:hacker) { create(:user) }
    let(:product) { create(:product, user: user) }
    let(:sold_product) { create(:product, user: user, status: 'sold') }

    it "destroys a product" do
      uuid = product.uuid
      Products::Destroy.call(user_id: user.uuid, id: uuid)
      expect(Product.find_by_uuid(uuid)).to be_nil
    end

    it 'enqueue jobs related to destroy product' do
      uuid = product.uuid
      # One for elastic search
      # One for timeline card cleaner
      expect do
        Products::Destroy.call(user_id: user.uuid, id: uuid)
      end.to change(enqueued_jobs, :size).by(2)
    end

    it "only the product owner can destroy product" do
      expect do
        Products::Destroy.call(user_id: hacker.uuid, id: product.uuid)
      end.to raise_error(ApiError::Unauthorized, "You don't have access to see the requested resource")
    end

    it "can't destroy product if the status is not published" do
      expect do
        Products::Destroy.call(user_id: user.uuid, id: sold_product.uuid)
      end.to raise_error(ApiError::FailedValidation, "Only published products can be deleted")
    end

    it "raises error when product doesn't exists" do
      expect do
        Products::Destroy.call(user_id: user.uuid, id: "invalid-id")
      end.to raise_error(ApiError::NotFound, "Product not found")
    end
  end
end
