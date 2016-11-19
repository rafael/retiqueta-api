class UserProductsCardSerializer < ActiveModel::Serializer
  type Timeline::Card::USER_PRODUCT_TYPE
  attributes :created_at, :products, :title
end
