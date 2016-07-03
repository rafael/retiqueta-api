#!/usr/bin/env bash
cd /app
eval "$(bundle exec rake secrets:export)"
dockerize -wait http://${KONG_ADMIN_SERVICE_HOST}:${KONG_ADMIN_SERVICE_PORT}/apis --timeout 360s
bundle exec unicorn -p 3000 -c ./config/unicorn.rb
