class TimelineFollowerProductCard < ActiveJob::Base
  queue_as :default

  def perform(user)
    product_count = products(user).count
    return unless product_count.even?
    create_card(user)
  end

  private

  def create_card(user)
    user.followers.each do |follower|
      Timeline::Card.create_products_card(
        title: I18n.t('timeline_cards.users_product_card_title', username: user.username),
        products: products(user)[0..1],
        card_type: Timeline::Card::USER_LIKES_TYPE,
        user_id: follower.uuid)
    end
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.warn("Trying to create duplicate card: #{e.message}")
  end

  def products(user)
    @products ||= Product.where(user_id: user.uuid).order(created_at: :desc)
  end

end
