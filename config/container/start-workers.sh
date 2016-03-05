#!/usr/bin/env bash
cd /app
eval "$(bundle exec rake secrets:export)"
bundle exec sidekiq -C config/sidekiq.yml
