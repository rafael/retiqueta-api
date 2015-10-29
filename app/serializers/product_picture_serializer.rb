class ProductPictureSerializer < ActiveModel::Serializer

  attributes :id, :position, :url, :user_id, :product_id

  def url
    case options[:image_size]
    when "small" then object.pic.url(:small)
    when "large" then object.pic.url(:large)
    else object.pic.url
    end
  end
end
