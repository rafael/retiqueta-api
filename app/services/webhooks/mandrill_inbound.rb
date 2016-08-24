module Webhooks
  class MandrillInbound
    def self.call(payload = {})
      Rails.logger.info "Received mandrill request with payload: #{payload}"
      msg = payload[:msg]
      return unless msg
      comment = msg[:text]
      return unless comment
      to = msg[:email]
      from = msg[:from_email]
      inbox, target_id = to.split('+')
      return unless inbox == 'producto'
      product = Product.find_by_uuid(target_id)
      return unless product
      user = User.find_by_email(from)
      return unless user
      data = {
        type: 'text_comments',
        attributes: {
          text: comment.strip
        }
      }
      Products::CreateComment.call(product_id: product.uuid,
                                   user_id: user.uuid,
                                   data: data)
    end
  end
end
