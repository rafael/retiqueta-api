class BackfillFollowerProductsCard < ActiveJob::Base
  queue_as :default

  def perform(follower, followed)
    followed
      .products
      .order(created_at: :desc)
      .find_in_batches(batch_size: 2)
      .each do |batch|
      break unless batch.size == 2
      Timeline::Card.create_products_card(
        title: I18n.t('timeline_cards.users_product_card_title',
                      username: followed.username),
        products: batch,
        created_at: batch.first.created_at,
        card_type: Timeline::Card::USER_LIKES_TYPE,
        user_id: follower.uuid)
    end
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.warn("Trying to create duplicate card: #{e.message}")
  end
end
