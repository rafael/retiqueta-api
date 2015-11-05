Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :stderr
  config.active_record.raise_in_transactional_callbacks = true
  config.x.kong.internal_url = "https://kong:8443"
  config.x.kong.users_ouath_token_path = "/users/oauth2/token"
  config.x.elastictsearch.host = "elasticsearch"
  config.x.elastictsearch.log = false

  config.paperclip_defaults = {
    storage: :fog,
    fog_credentials:  {
      provider: "AWS",
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    },
    fog_directory: ENV['S3_BUCKET_NAME'],
  }

end
