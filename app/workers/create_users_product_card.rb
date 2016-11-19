class CreateUsersProductCard < ActiveJob::Base
  queue_as :default

  def perform(user)
    pCount = products(user).count
    return unless pCount.even?
    create_card(user)
  end

  private

  def create_card(user)
    Timeline::Card.create_products_card(
      title: user.username + ' ' + I18n.t('timeline_cards.users_product_card_title'),
      products: products(user),
      card_type: Timeline::Card::USER_PRODUCT_TYPE,
      user_id: user.uuid)
  end

  def products(user)
    @products ||= Product.where(user_id: user.id)
  end
end
