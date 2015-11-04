module PushNotifications
  class Create

    # Instance Methods
    attr_accessor :message

    def self.call(params)
      service = self.new(params)
      service.notificate
    end

    # To: most be a integer with the device token or and array with multiple devices tokens
    # data: is a hash with gcm data field
    # extras: could be any aditional configuration than is soported on GCM
    # broadcast: if the menssage has multiple destinations (true/false)
    def initialize(to, data, extras = {})
      @params = {to: to}
        .merge({ data: data })
        .merge(extras)
      @message = GCM.new(@params)
      @message.valid?
    end

    def notificate
      @message.notificate
    end
  end

  class ResultParser
    attr_reader :result

    def initialize(result)
      @result = result
    end

    def parse
      # Todo define what we want to do with the GCM response, this will define what parse do
      # and what happend after parse that response.

      #case @result.status
      # when 401
      #   true
      # else
      #   true
      # end
    end

  end

end
