#!/bin/bash
# run_rspec.sh
export RAILS_ENV=test
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rspec
