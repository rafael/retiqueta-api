require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RetiquetaApi
  class Application < Rails::Application
    config.active_job.queue_adapter = :sidekiq
    config.i18n.default_locale = :es
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
