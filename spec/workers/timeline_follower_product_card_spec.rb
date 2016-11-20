require "rails_helper"

RSpec.describe TimelineFollowerProductCard, type: :job do
  include ActiveJob::TestHelper
  let(:user) { create(:user, password: '123456') }
  let(:followed_user) { create(:user) }

  it 'creates timeline cards for user followers' do
    Users::Follow.call(follower_id: user.uuid, followed_id: followed_user.uuid)
    create(:product, title: 'zapato super #nike', user: followed_user)
    create(:product, title: 'zapato super #nike', user: followed_user)

    TimelineFollowerProductCard.perform_now(followed_user)
    expect(Timeline::Card.count).to eq(1)
  end

end
