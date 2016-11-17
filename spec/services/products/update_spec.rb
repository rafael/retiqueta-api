require 'rails_helper'

RSpec.describe Products::Create, type: :model do
  describe ".call" do
    INVALID_ID = 12345
    let(:user) { create(:user) }
    let(:picture1) { create(:product_picture, user: user) }
    let(:picture2) { create(:product_picture, user: user) }
    let(:picture3) { create(:product_picture, user: user) }
    let(:product_pictures) { [picture1, picture2, picture3] }
    let(:product_picture_ids) { product_pictures.map(&:id) }
    let(:param_pictures) { [] }
    let(:product) { create(:product, user: user, product_pictures: product_pictures) }
    let(:params) {
      {
        id: product.uuid,
        user_id: product.user_id,
        data: {
          type: "products",
          attributes: {
            category: "dummy_category",
            title: "dummy_title",
            description: "dummy_description",
            original_price: 1,
            price: 2,
            size: "XL",
            pictures: param_pictures
          }
        }
      }
    }

    it "updates a product when valid parameters are provided" do
      service_result = Products::Update.call(params)
      expect(service_result.success_result).to eq(product)
      result_product = service_result.success_result
      expect(result_product.category).to eq("dummy_category")
      expect(result_product.title).to eq("dummy_title")
      expect(result_product.description).to eq("dummy_description")
      expect(result_product.original_price).to eq(1)
      expect(result_product.price).to eq(2)
      expect(result_product.size).to eq("XL")
    end

    it "updates images unless they are empty or not provided" do
      result_product = Products::Update.call(params).success_result
      expect(result_product.product_pictures.map(&:id).to_set).to eq(product_picture_ids.to_set)
    end

    context "when pictures are not empty" do
      let(:param_pictures) { [picture3.id, picture1.id] }

      it "updates product pictures and preserves the order they were provided" do
        result_product = Products::Update.call(params).success_result
        expect(result_product.product_pictures.order("position asc").map(&:id)).to eq(param_pictures)
      end
    end

    context "when some of the pictures are invalid" do
      let(:param_pictures) { [picture1.id, INVALID_ID] }

      it "raises an error" do
        expect do
          Products::Update.call(params)
        end.to raise_error(ApiError::FailedValidation, I18n.t("product.errors.invalid_pictures"))
      end
    end

    it "requires a valid user id" do
      expect do
        Products::Update.call(params.merge(user_id: INVALID_ID))
      end.to raise_error(ApiError::NotFound, I18n.t("user.errors.not_found"))
    end

    it "requires a valid product id" do
      expect do
        Products::Update.call(params.merge(id: INVALID_ID))
      end.to raise_error(ApiError::NotFound, I18n.t("product.errors.not_found"))
    end

    it "requires resource type to be equal to products" do
      params[:data][:type] = "xxx"
      message = I18n.t("errors.invalid_type", type: "xxx", resource_type: "products")
      expect do
        Products::Update.call(params)
      end.to raise_error(ApiError::FailedValidation, message)
    end
  end
end
