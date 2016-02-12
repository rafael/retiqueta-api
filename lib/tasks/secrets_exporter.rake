namespace :secrets do
  desc "Export contents from secret paths to environment variables"
  task export: :environment do
    next if secret_paths.empty?
    secret_paths.each { |path| export_secret_files(path) }
  end

  # Helpers

  def secret_paths
    @secret_paths ||= ENV["SECRET_PATHS"].split(",")
  end

  def export_secret_files(path)
    each_secret_file(path) do |file|
      env_var = file_to_env_var(file)
      print_env_var(env_var)
    end
  end

  def file_to_env_var(file)
    {
      key: File.basename(file).gsub("-", "_").upcase,
      value: File.read(file).strip
    }
  end

  def print_env_var(env_var)
    puts "export #{env_var[:key]}=#{env_var[:value]}"
  end

  def each_secret_file(path, &block)
    Dir["#{path}/**/*"].each do |file|
      yield(file) if !file.include?(".") && File.file?(file)
    end
  end
end
