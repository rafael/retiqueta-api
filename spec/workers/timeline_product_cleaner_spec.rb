require "rails_helper"

RSpec.describe TimelineProductCleaner, type: :job do
  include ActiveJob::TestHelper

  before do
    (1..2).each { create(:product) }
    Timeline::Card.create_featured_picks_card('Test', Product.last(3))
  end

  it 'does nothing when no timeline cards match the id' do
    TimelineProductCleaner.perform_now('dummy_id')
    expect(Timeline::Card.count).to eq(1)
  end

  it 'deletes product when a timeline card exists' do
    TimelineProductCleaner.perform_now(Product.last.uuid)
    expect(Timeline::Card.count).to eq(0)
  end
end
