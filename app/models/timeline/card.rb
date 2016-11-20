class Timeline::Card < ActiveRecord::Base

  before_save :update_checksum

  FEATURED_PICKS_TYPE = 'featured_picks'
  USER_LIKES_TYPE = 'user_likes'
  USER_PRODUCT_TYPE = 'user_products'

  def self.create_products_card(args = {})
    title = args.fetch(:title)
    products = args.fetch(:products)
    card_type = args.fetch(:card_type, FEATURED_PICKS_TYPE)
    user_id = args[:user_id]
    created_at = args[:created_at]
    json_products = products.map do |p|
      {
        id: p.uuid,
        image_large_url: p.product_pictures.first.pic.url(:large),
        image_medium_url:   p.product_pictures.first.pic(:medium),
        image_small_url:   p.product_pictures.first.pic(:small)
      }
    end
    payload = { products: json_products, product_ids: json_products.map { |p| p[:id] } }
    self.create(title: title,
                payload: payload,
                created_at: created_at,
                card_type: card_type,
                user_id: user_id)
  end

  def json_ast
    json_ast = {
      id: id,
      created_at: created_at,
      title: title
    }.merge(payload)
    json_ast_struct = OpenStruct.new(json_ast.merge(attributes: json_ast))
    json_ast_struct.extend(ActiveModel::Serializers::JSON)
    json_ast_struct
  end

  def serializer
    "#{card_type.camelize}CardSerializer".constantize
  end

  private

  def update_checksum
    self.checksum = Digest::SHA256.hexdigest({ user_id: user_id,
                                               payload: payload,
                                               card_type: card_type,
                                               title: title
                                             }.to_json)
  end
end
