require 'push_notification_client'

class SendPushNotification < ActiveJob::Base
  queue_as :push

  def client
    @client ||= PushNotificationClient.new
  end

  def perform(users, title, message, payload)
    response = client.send_push(user_ids: users.map(&:uuid),
                                title: title,
                                message: message,
                                payload: payload)
    Rails.logger.info(response.body)
  end

end
