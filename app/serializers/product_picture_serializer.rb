class ProductPictureSerializer < ActiveModel::Serializer

  attributes :id, :position, :url, :small_url, :large_url, :product_id

  def large_url
    object.pic.url(:large)
  end

  def small_url
    object.pic(:small)
  end

  def url
    object.pic.url
  end
end
