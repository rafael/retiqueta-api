class FollowerSerializer < ActiveModel::Serializer
  attributes :username, :id

  attribute :uuid, key: :id
end
