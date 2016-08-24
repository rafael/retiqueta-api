module Webhooks
  class MandrillInbound
    def self.call(params = {})
      Rails.logger.info "Received mandrill request with payload: #{params.to_json}"
      mandrill_events = params[:mandrill_events]
      return unless mandrill_events
      parsed_events = JSON.parse(mandrill_events)
      parsed_events.each do |payload|
        msg = payload['msg']
        next unless msg
        comment = msg['text']
        next unless comment
        to = msg['email']
        from = msg['from_email']
        inbox, target_id = to.split('+')
        next unless inbox == 'producto'
        product = Product.find_by_uuid(target_id)
        next unless product
        user = User.find_by_email(from)
        next unless user
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
end
