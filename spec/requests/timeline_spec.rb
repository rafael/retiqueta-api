require 'rails_helper'

RSpec.describe 'Timeline request', type: :request do
  let(:user) { create(:user, password: '123456') }
  let(:followed_user) { create(:user) }

  it 'returns timeline cards with user_likes plus retiqueta_picks' do
    create(:product, title: 'zapato super #nike')
    create(:product, title: 'zapato super #nike')
    create(:product, title: 'zapato super #nike')

    (1..5).each do |card|
      Timeline::Card.create_products_card(
        title: "retiqueta_pick test #{card}",
        products: Product.last(3))
    end

    (1..3).each do |card|
      Timeline::Card.create_products_card(
        title: "user_like test #{card}",
        user_id: user.uuid,
        card_type: Timeline::Card::USER_LIKES_TYPE,
        products: Product.last(2))
    end

    get '/v1/timeline', { page: { number: 1, size: 5 } }, 'X-Authenticated-Userid' => user.uuid
    expect(response.status).to eq(200)
    expect(json['data'].count).to eq(5)
    expected_result = %w(user_likes
                         user_likes
                         user_likes
                         featured_picks
                         featured_picks)
    expect(json['data'].map { |d| d['type'] }).to eq(expected_result)
  end

  it 'second page only have retiqueta picks' do
    create(:product, title: 'zapato super #nike')
    create(:product, title: 'zapato super #nike')
    create(:product, title: 'zapato super #nike')

    (1..3).each do |card|
      Timeline::Card.create_products_card(
        title: "user_like test #{card}",
        user_id: user.uuid,
        card_type: Timeline::Card::USER_LIKES_TYPE,
        products: Product.last(2))
    end

    (1..5).each do |card|
      Timeline::Card.create_products_card(
        title: "retiqueta_picks #{card}",
        products: Product.last(3))
    end

    get '/v1/timeline', { page: { number: 2, size: 2 } }, 'X-Authenticated-Userid' => user.uuid
    expect(response.status).to eq(200)
    expect(json['data'].count).to eq(2)
  end
end
