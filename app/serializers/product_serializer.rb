class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :category, :original_price, :currency

  attribute :uuid, key: :id
end
