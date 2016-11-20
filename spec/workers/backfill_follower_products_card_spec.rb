require "rails_helper"

RSpec.describe BackfillFollowerProductsCard, type: :job do
  let(:followed) { create(:user) }
  let(:follower) { create(:user) }
  let(:followed_with_three_products) { create(:user) }

  before do
    (1..10).each { create(:product, user: followed) }
  end

  it 'creates product card when there are more than two products' do
    expect do
      described_class.perform_now(follower, followed)
    end.to change { Timeline::Card.where(user_id: follower.uuid).count }.by(5)
  end

  it 'only creates every two products card' do
    (1..3).each { create(:product, user: followed_with_three_products) }
    expect do
      described_class.perform_now(follower, followed_with_three_products)
    end.to change { Timeline::Card.where(user_id: follower.uuid).count }.by(1)
  end

  it 'uses created_at from product' do
    (1..2).each { create(:product, user: followed_with_three_products, created_at: 2.days.ago) }
    expect do
      described_class.perform_now(follower, followed_with_three_products)
    end.to change { Timeline::Card.where(user_id: follower.uuid).count }.by(1)
    # why last instead of first ? Not sure
    expect(Timeline::Card.last.created_at).to eq(followed_with_three_products.products.order(created_at: :desc).last.created_at)
  end

  it 'card creation is idempotent' do
    expect do
      described_class.perform_now(follower, followed)
      described_class.perform_now(follower, followed)
    end.to change { Timeline::Card.where(user_id: follower.uuid).count }.by(5)
  end
end
