require 'open-uri'

class PinterestProductCreator < ActiveJob::Base
  queue_as :default

  def perform(product)
    web_contents  = open( product.product_pictures.first.pic.url) {|f| f.read }
    client.create_pin(board: "#{Rails.configuration.x.pinterest_user}/picks",
                       note: product.description,
                       link: 'https://www.retiqueta.com',
                       image_base64: Base64.strict_encode64(web_contents)
                      )
  end

  def client
    @client ||= Pinterest::Client.new(Rails.application.secrets.pinterest_access_token)
  end
end
