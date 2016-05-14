require 'rails_helper'

RSpec.describe Products::Create, type: :model do
  describe '.call' do
    let(:user) { create(:user) }
    let(:picture) { create(:product_picture, user: user) }
    let(:picture_2) { create(:product_picture, user: user) }
    let(:params) do
      {
        user_id: user.uuid,
        data: {
          type: 'products',
          attributes: {
            category: 'shoes',
            title: 'My awesome shoes',
            description: 'Estos zapatos tienen mucha historia conmigo',
            original_price: 60,
            price: 40,
            pictures: [picture.id],
            size: '8'
          }
        }
      }
    end

    it 'creates a product when valid parameters are provided' do
      service_result = Products::Create.call(params)
      expect(service_result.success_result).to eq(Product.last)
      product = service_result.success_result
      expect(product.status).to eq('published')
      expect(product.user).to eq(user)
      expect(product.product_pictures).to eq([picture])
      expect(product.size).to eq('8')
    end

    it 'fails when trying to reuse picture id' do
      Products::Create.call(params)
      expect do
        Products::Create.call(params)
      end.to raise_error(ApiError::FailedValidation, 'The provided picture ids are not valid, they are already in used by a different product')
    end

    it 'picture position gets set in the order they were provided' do
      new_params = params
      new_params[:data][:attributes][:pictures] = [picture_2.id, picture.id]
      service_result = Products::Create.call(params)
      expect(service_result.success_result).to eq(Product.last)
      product = service_result.success_result
      expect(product.status).to eq('published')
      expect(product.product_pictures.order('position asc')).to eq([picture_2, picture])
    end

    it 'requires a valid user id' do
      expect do
        Products::Create.call(params.merge(user_id: 12_323))
      end.to raise_error(ApiError::NotFound, 'User not found')
    end

    [:title, :category, :description, :price, :pictures].each do |required_attribute|
      it 'throws error if required attribute is missing' do
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
