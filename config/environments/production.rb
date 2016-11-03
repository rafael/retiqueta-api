Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.log_level = (ENV['LOG_LEVEL'] || :info).to_sym

  config.log_tags = [:uuid,
                     ->(req) { req.headers['X-Authenticated-Userid'] || '-' }]

  config.logger = Logger.new(STDOUT)

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.log_formatter = ::Logger::Formatter.new

  config.active_record.raise_in_transactional_callbacks = true

  config.active_record.dump_schema_after_migration = false

  config.x.kong.external_host = 'api.retiqueta.com'
  config.x.kong.external_port = 443

  config.x.kong.internal_url = "https://#{ENV['KONG_PORT_443_TCP_ADDR']}"
  config.x.kong.users_ouath_token_path = '/v1/users/oauth2/token'
  config.x.elastictsearch.host = 'elasticsearch'
  config.x.elastictsearch.log = true
  config.x.reset_password_url = 'https://www.retiqueta.com/#/update-password/{{token}}'
  config.x.pinterest_user = ENV['PINTEREST_USER']

  config.paperclip_defaults = {
    storage: :fog,
    fog_credentials:  {
      provider: 'AWS',
      region: 'us-west-1',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    },
    fog_directory: ENV['S3_BUCKET_NAME'],
    fog_host: 'https://d3e4hek1qnfih2.cloudfront.net'
  }
end
