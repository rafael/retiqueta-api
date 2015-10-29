require 'rails_helper'

RSpec.describe Products::Create, type: :model do
  describe ".call" do
    let(:user) { create(:user) }
    let(:picture) { create(:product_picture, user: user) }
    let(:params) {
      {
        user_id: user.uuid,
        data: {
          type: "products",
          attributes: {
            category: "shoes",
            title: "My awesome shoes",
            description: "Estos zapatos tienen mucha historia conmigo",
            original_price: 60,
            price: 40,
            pictures: [picture.id]
          }
        }
      }
    }

    it "creates a product when valid parameters are provided" do
      service_result = Products::Create.call(params)
      expect(service_result.success_result).to eq(Product.last)
      product = service_result.success_result
      expect(product.product_pictures).to eq([picture])
    end

    it "requires a valid user id" do
      expect do
        Products::Create.call(params.merge(user_id: 12323))
      end.to raise_error(ApiError::NotFound, "User not found")
    end

    [:title, :category, :description, :price, :pictures].each do |required_attribute|
      it "throws error if required attribute is missing" do
        new_params = params
        attributes = params[:data][:attributes]
        new_params[:data][:attributes] = attributes.except(required_attribute)
        expect do
          Products::Create.call(params)
        end.to raise_error(ApiError::FailedValidation, "#{required_attribute.capitalize} can't be blank")
      end
    end
  end
end
