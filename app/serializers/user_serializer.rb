class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :username, :email

  attribute :uuid, key: :id
end
