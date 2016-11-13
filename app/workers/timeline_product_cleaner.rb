class TimelineProductCleaner < ActiveJob::Base
  queue_as :default

  def perform(product_id)
    Timeline::Card
      .where(card_type: [Timeline::Card:: FEATURED_PICKS_TYPE,
                         Timeline::Card::USER_LIKES_TYPE])
      .where("payload -> 'product_ids' ? :id ", id: product_id).destroy_all
  end
end
