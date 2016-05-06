class PushNotificationClient
  PRODUCTION_PROFILE_NAME = 'production'

  def send_push(params = {})
    payload = {
      tokens: params.fetch(:tokens),
      profile: params.fetch(:profile, PRODUCTION_PROFILE_NAME),
      notification: {
        android: {
          title: params.fetch(:title),
          message: params.fetch(:message),
          payload: params.fetch(:payload, {})
        },
        ios: {
          title: params.fetch(:title),
          message: params.fetch(:message),
          payload: params.fetch(:payload, {})
        }
      }
    }
    conn.post('/push/notifications', payload.to_json)
  end

  def conn
    @conn ||= begin
                headers = {
                  'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{Rails.application.secrets.ionic_access_token}"
                }
                conn_options = {
                  url: 'https://api.ionic.io',
                  headers: headers
                }
                Faraday.new(conn_options) do |connection|
                  connection.adapter Faraday.default_adapter
                end
              end
  end
end
