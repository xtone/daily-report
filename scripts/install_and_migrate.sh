#!/bin/bash

source /etc/environment
source /home/ec2-user/.bash_profile

export PATH RAILS_ENV RAILS_HOME DB_HOST DB_USERNAME DB_PASSWORD SECRET_KEY_BASE

cd /home/ec2-user/daily-report
RAILS_ENV=production bin/bundle install --path ../vendor/bundle
RAILS_ENV=production bin/rails db:create
RAILS_ENV=production bin/rails db:migrate
RAILS_ENV=production bin/rails assets:precompile

RAILS_ENV=production bin/rails yarn:install
RAILS_ENV=production bin/rails webpacker:compile
