#!/usr/bin/env bash
cd /app
bundle exec unicorn -p 3000 -c ./config/unicorn.rb
