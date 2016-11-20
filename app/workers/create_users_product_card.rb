class CreateUsersProductCard < ActiveJob::Base
  queue_as :default

  def perform(user)
    product_count = products(user).count
    return unless product_count.even?
    create_card(user)
  end

  private

  def create_card(user)
    @products ||= Product.where(user_id: user.id).last(2)
    user.followers.each do |follower|
      Timeline::Card.create_products_card(
        title: I18n.t('timeline_cards.users_product_card_title', username: user.username),
        products: @products,
        card_type: Timeline::Card::USER_PRODUCT_TYPE,
        user_id: follower.uuid)
    end
  end

end
