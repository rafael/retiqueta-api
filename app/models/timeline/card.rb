class Timeline::Card < ActiveRecord::Base

  FEATURED_PICKS_TYPE = 'featured_picks'

   def self.create_featured_picks_card(title, products)
     json_products = products.map do |p|
       {
         id: p.uuid,
         image_large_url: p.product_pictures.first.pic.url(:large),
         image_medium_url:   p.product_pictures.first.pic(:medium),
         image_small_url:   p.product_pictures.first.pic(:small)
       }
     end
     payload = { products: json_products }
     self.create(title: title, payload: payload, card_type: FEATURED_PICKS_TYPE)
   end

  def as_json(options = {})
    json_ast = {
      id: id,
      created_at: created_at,
      title: title
    }.merge(payload)
    json_ast_struct = OpenStruct.new(json_ast.merge(attributes: json_ast))
    json_ast_struct.extend(ActiveModel::Serializers::JSON)
    ActiveModel::Serializer::Adapter.create(serializer.new(json_ast_struct)).as_json(options)
  end

  def serializer
    "#{card_type.camelize}CardSerializer".constantize
  end
end
