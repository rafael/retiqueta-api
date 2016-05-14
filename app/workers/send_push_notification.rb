require 'push_notification_client'

class SendPushNotification < ActiveJob::Base
  queue_as :push

  def client
    @client ||= PushNotificationClient.new
  end

  def perform(users, title, message, payload)
    users.each do |user|
      response = client.send_push(tokens: user.push_tokens.where(environment: 'production').map(&:token),
                                  title: title,
                                  message: message,
                                  payload: payload)
      Rails.logger.info(response.body)
    end
  end

end
