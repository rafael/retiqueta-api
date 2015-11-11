#!/usr/bin/env bash
cd /app
bundle exec rake db:create
eval "$(bundle exec rake kong:setup)"
bundle exec unicorn -p 3000 -c ./config/unicorn.rb
