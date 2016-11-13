require "rails_helper"

RSpec.describe CreateUsersLikeCard, type: :job do
  let(:user) { create(:user) }

  before do
    (1..10).each { create(:product) }
  end

  it 'does nothing when the likes are odd' do
    Product.first.liked_by(user)
    CreateUsersLikeCard.perform_now(user)
    user_cards = Timeline::Card
                 .where(user_id: user.uuid)
                 .where(card_type: Timeline::Card::USER_LIKES_TYPE)
    expect(user_cards.count).to eq(0)
  end

  it 'created card when likes are even' do
    Product.first.liked_by(user)
    Product.last.liked_by(user)
    CreateUsersLikeCard.perform_now(user)
    user_cards = Timeline::Card
                 .where(user_id: user.uuid)
                 .where(card_type: Timeline::Card::USER_LIKES_TYPE)
    expect(user_cards.count).to eq(1)
    expect(user_cards.first.payload["product_ids"].to_set)
      .to eq([Product.first.uuid, Product.last.uuid].to_set)
  end

  it 'caps user likes to 3 cards' do
    products = Product.all
    products[0].liked_by(user)
    products[1].liked_by(user)
    CreateUsersLikeCard.perform_now(user)
    user_cards = Timeline::Card
                 .where(user_id: user.uuid)
                 .where(card_type: Timeline::Card::USER_LIKES_TYPE)
    expect(user_cards.count).to eq(1)
    products[2].liked_by(user)
    products[3].liked_by(user)
    CreateUsersLikeCard.perform_now(user)
    user_cards = Timeline::Card
                 .where(user_id: user.uuid)
                 .where(card_type: Timeline::Card::USER_LIKES_TYPE)
    expect(user_cards.count).to eq(2)
    products[4].liked_by(user)
    products[5].liked_by(user)
    CreateUsersLikeCard.perform_now(user)
    user_cards = Timeline::Card
                 .where(user_id: user.uuid)
                 .where(card_type: Timeline::Card::USER_LIKES_TYPE)
    expect(user_cards.count).to eq(3)
    products[5].liked_by(user)
    products[6].liked_by(user)
    CreateUsersLikeCard.perform_now(user)
    user_cards = Timeline::Card
                 .where(user_id: user.uuid)
                 .where(card_type: Timeline::Card::USER_LIKES_TYPE)
    expect(user_cards.count).to eq(3)
  end
end
