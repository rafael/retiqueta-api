namespace :es do
  desc "Setup elastict search"
  task setup: :environment do
    Product.__elasticsearch__.create_index!
  end
end
