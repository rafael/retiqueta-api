class GCM

  # Module inclussion
  include ActiveSupport::Configurable
  include ActiveModel::Validations

  # Geters, Setters
  attr_accessor :to, :data

  # Validations
  validates :to, :data, presence: true

  # Configurations Accessors
  config_accessor :server_key, instance_reader: true, instance_writer: false

  # Constants
  GCM_API_URL = 'https://gcm-http.googleapis.com'

  def initialize(params = {})
    @params = params.to_json
    params.each { |k,v| instance_variable_set("@#{k}", v) }

    @conn = Faraday.new(:url => GCM_API_URL) do |faraday|
      faraday.response :logger                  # log requests to STDOUT
      faraday.use Authorization
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def notificate
    if valid?
      @conn.post '/gcm/send', @params
    else
      false
    end
  end
end

# Faraday Authorization Middleware
class Authorization < Faraday::Middleware
  def call(request_env)
    request_env[:request_headers].merge!({
      'Content-Type': 'application/json',
      'Authorization': "key=#{GCM.server_key}"
    })
    @app.call(request_env)
  end
end
