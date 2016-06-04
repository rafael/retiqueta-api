#!/usr/bin/env bash
cd /app
dockerize -wait tcp://db:5432 --timeout 360s
bundle exec rake db:create
bundle exec rake db:migrate
dockerize -wait http://${KONG_ADMIN_SERVICE_HOST}:${KONG_ADMIN_SERVICE_PORT}/apis --timeout 360s
eval "$(bundle exec rake kong:setup)"
bundle exec unicorn -p 3000 -c ./config/unicorn.rb
