#!/usr/bin/env bash
cd /app
eval "$(bundle exec rake secrets:export)"
bundle exec unicorn -p 3000 -c ./config/unicorn.rb
