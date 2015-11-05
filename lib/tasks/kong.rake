namespace :kong do
  desc "Setup kong for development"
  task setup: :environment do
    next if ENV["API_IP_PORT"].blank?

    wait_for_kong

    puts config.inspect

    # delete all apis
    list_apis.each { |api| delete_api(api["name"]) }

    # create apis
    config["apis"].each { |api_config| create_api(api_config) }

    # setup plugins
    config["plugins"].each { |plugin_config| add_plugin(plugin_config) }

    # retrieve consumer
    consumer = find_or_create_consumer(config["consumer"])

    # retrieve application
    app = find_or_create_application(config["outh2_application"], config["consumer"]["username"])

    variables["KONG_CLIENT_ID"] = app["client_id"]
    variables["KONG_CLIENT_SECRET"] = app["client_secret"]

    # print variables in a export format to evaluated
    variables.each { |key, value| puts "export #{key}=#{value}" }
  end



  # Helpers

  def wait_for_kong
    kong_admin.head("/")
  rescue
    sleep(1)
    retry
  end

  def variables
    @variables ||= {}
  end

  def config
    @config ||= begin
      config_file = Rails.root.join("config/kong.yml")
      yaml = ERB.new(File.read(config_file)).result
      YAML.load(yaml)
    end
  end

  def create_api(api_config)
    log "creating API: #{api_config["name"]}"
    response = kong_admin.post("/apis", URI.encode_www_form(api_config))
  end

  def delete_api(name)
    log "deleting API: #{name}"
    response = kong_admin.delete("/apis/#{name}")
    log "API does not exist" if response.status == 404
  end

  def list_apis
    response = kong_admin.get("/apis")
    JSON.parse(response.body)["data"]
  end

  def find_or_create_consumer(consumer_config)
    username = consumer_config["username"]
    log "fetching consumer: #{username}"
    response = kong_admin.get("/consumers/#{username}")

    if response.status == 404
      log "creating consumer: #{username}"
      response = kong_admin.post("/consumers", URI.encode_www_form(consumer_config))
    end

    JSON.parse(response.body)
  end

  def find_or_create_application(app_config, consumer_name)
    app_name = app_config["name"]
    log "fetching application: #{app_name}"
    response = kong_admin.get("/consumers/#{consumer_name}/oauth2")
    app = JSON.parse(response.body)["data"].find { |app| app["name"] == app_name }
    unless app
      log "creating application"
      response = kong_admin.post(
        "/consumers/#{consumer_name}/oauth2",
        URI.encode_www_form(app_config))

      app = JSON.parse(response.body)
    end

    app
  end

  def add_plugin(plugin_config)
    apis =
      case plugin_config["apis"]
      when "all"
        config["apis"].map { |api| api["name"] }
      else
        plugin_config["apis"] || []
      end

    # Remove this key as it's not a valid parameter
    pc = plugin_config.dup
    pc.delete("apis")

    apis.each do |api_name|
      log "adding plugin: #{pc["name"]} to API: #{api_name}"
      response = kong_admin.post("/apis/#{api_name}/plugins", URI.encode_www_form(pc))

      # fetch any provision key for ouath2
      if pc["name"] == "oauth2"
        provision_key = JSON.parse(response.body)["config"]["provision_key"]
        variables["KONG_CLIENT_PROVISION_KEY"] = provision_key
      end
    end
  end

  def log(*msgs)
    msgs.each { |msg| puts "# #{msg}" }
  end

  def kong_admin
    @client ||= begin
      options = {
        url: "http://kong:8001",
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded",
          "Accept" => "application/json",
        }
      }

      Faraday.new(options) { |conn| conn.adapter(Faraday.default_adapter) }
    end
  end
end
