require "rails_helper"

RSpec.describe TimelineProductCleaner, type: :job do
  include ActiveJob::TestHelper

  before do
    (1..2).each { create(:product) }
  end

  it 'does nothing when no timeline cards match the id' do
    Timeline::Card.create_products_card(
      title: 'Test',
      products: Product.last(3))
    TimelineProductCleaner.perform_now('dummy_id')
    expect(Timeline::Card.count).to eq(1)
  end

  it 'deletes product when a timeline card exists' do
    Timeline::Card.create_products_card(
      title: 'Test',
      products: Product.last(3))
    TimelineProductCleaner.perform_now(Product.last.uuid)
    expect(Timeline::Card.count).to eq(0)
  end

  it 'deletes product when there is timeline user_like card' do
    Timeline::Card.create_products_card(
      title: 'Test',
      card_type: Timeline::Card::USER_LIKES_TYPE,
      products: Product.last(3))
    TimelineProductCleaner.perform_now(Product.last.uuid)
    expect(Timeline::Card.count).to eq(0)
  end
end
