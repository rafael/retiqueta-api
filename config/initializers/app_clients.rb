module AppClients
  def redis
    @redis ||=
      Redis.new(url: "redis://#{ENV['REDIS_SERVICE_HOST']}:#{ENV['REDIS_SERVICE_PORT']}/retiqueta")
  end
  module_function :redis
end
