class UserLikesCardSerializer < ActiveModel::Serializer
  type Timeline::Card::USER_LIKES_TYPE
  attributes :created_at, :products, :title
end
