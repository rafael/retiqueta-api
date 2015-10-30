class GCM
  include ActiveSupport::Configurable
  config_accessor :server_key, instance_reader: true, instance_writer: false
  GCM_API_URL = 'https://gcm-http.googleapis.com'

  def initialize(params = {})
    @params = params
    @conn = Faraday.new(:url => GCM_API_URL) do |faraday|
      faraday.response :logger                  # log requests to STDOUT
      faraday.use Authorization
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def send
    @conn.post '/gcm/send', @params.to_json
  end
end

class Authorization < Faraday::Middleware
  def call(request_env)
    request_env[:request_headers].merge!({
      'Content-Type': 'application/json',
      'Authorization': "key=#{GCM.server_key}"
    })
    @app.call(request_env)
  end
end
