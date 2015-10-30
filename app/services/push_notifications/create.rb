module PushNotifications
  class Create

    # Instance Methods
    attr_accessor :message

    def self.call(params)
      service = self.new(params)
      service.message.valid?
      service.notificate
    end

    def initialize(to, data, extras = {}, broadcast = false)
      @params = CreateFormater.new.format(to, broadcast)
        .merge({ data: data })
        .merge(extras)

      @message = GCM.new(@params)
    end

    def notificate
      parser = ResultParser.new(@message.notificate)
    end
  end

  class ResultParser
    attr_reader :result

    def initialize(result)
      @result = result
    end

    def parse
      case @result.status
      when 401
        true
      else
        true
      end
    end

  end

  class CreateFormater
    def format(to, broadcast)
      result = {
        to: (broadcast) ? to.first : to
      }
      (broadcast) ? result.merge({registration_ids: to[1..-1]}) : result
    end
  end

end
