#!/usr/bin/env bash
cd /app
eval "$(bundle exec rake secrets:export)"
dockerize -wait http://${KONG_ADMIN_SERVICE_HOST}:${KONG_ADMIN_SERVICE_PORT}/apis
mkdir -p /etc/ssl/kong
echo $RETIQUETA_SSL_API_PEM > /etc/ssl/kong/api.retiqueta.pem
echo $RETIQUETA_SSL_API_KEY > /etc/ssl/kong/api.retiqueta.key
eval "$(bundle exec rake kong:setup)"
bundle exec unicorn -p 3000 -c ./config/unicorn.rb
