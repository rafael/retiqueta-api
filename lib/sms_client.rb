class SmsClient
  def send_sms(params = {})
    payload = {
      mensaje: params.fetch(:msg),
      telefono: params.fetch(:mobile),
      cuenta_token: params.fetch(:token, '9c2db7e0fbcd4e7bd0c531cbdd4836dfb4a358ff'),
      aplicacion_token: params.fetch(:app_token, '25fe24954de8f63412242d1af5a1f8f7ce58ef2d'),
    }
    conn.post('/sms/enviar', payload)
  end

  def conn
    @conn ||= begin
                conn_options = {
                  url: 'http://api.textveloper.com/sms/enviar',
                }
                Faraday.new(conn_options) do |connection|
                  connection.request  :url_encoded             # form-encode POST params
                  connection.adapter Faraday.default_adapter
                end
              end
  end
end
