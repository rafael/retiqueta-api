require 'sms_client'

class SendSmsWorker < ActiveJob::Base
  queue_as :push

  def client
    @client ||= SmsClient.new
  end

  def perform(msg, mobile, token, app_token)
    if token && app_token
      response = client.send_sms(msg: msg,
                                  mobile: mobile,
                                  token: token,
                                  app_token: app_token)
      Rails.logger.info(response.body)
    else
      response = client.send_sms(msg: msg,
                                 mobile: mobile)
      Rails.logger.info(response.body)
    end
  end
end
