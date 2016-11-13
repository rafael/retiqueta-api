class CreateUsersLikeCard < ActiveJob::Base
  queue_as :default

  MAX_NUMBER_OF_CARDS = 3

  def perform(user)
    likes_count = user_likes(user).count
    return unless likes_count.even? || likes_count == 0
    create_card(user)
    clean_cards(user)
  end

  private

  def create_card(user)
    Timeline::Card.create_products_card(
      title: I18n.t('timeline_cards.users_like'),
      products: products(user),
      card_type: Timeline::Card::USER_LIKES_TYPE,
      user_id: user.uuid)
  end

  def clean_cards(user)
    total_cards = Timeline::Card
                  .where(user_id: user.uuid)
                  .where(card_type: Timeline::Card::USER_LIKES_TYPE)
                  .last(4)
    return if total_cards.size <= MAX_NUMBER_OF_CARDS
    total_cards[MAX_NUMBER_OF_CARDS..-1].map(&:destroy)
  end

  def product_ids(user)
    user_likes(user)
      .last(2)
      .map(&:votable_id)
  end

  def user_likes(user)
    @user_likes ||= user.votes.up.where(votable_type: 'Product')
  end

  def products(user)
    @products ||= Product.where(id: product_ids(user))
  end
end
