#!/usr/bin/env bash
cd /app
eval "$(LIBRATO_AUTORUN=0 bundle exec rake secrets:export)"
bundle exec sidekiq -C config/sidekiq.yml
