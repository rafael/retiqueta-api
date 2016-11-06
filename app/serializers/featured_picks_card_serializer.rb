class FeaturedPicksCardSerializer < ActiveModel::Serializer
  type Timeline::Card::FEATURED_PICKS_TYPE
  attributes :created_at, :products, :title
end
