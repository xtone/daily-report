#!/bin/bash

chown -R ec2-user:ec2-user /home/ec2-user/daily-report

cd /home/ec2-user/daily-report
RAILS_ENV=production bin/bundle install --path vendor/bundle
RAILS_ENV=production bin/rails db:create
RAILS_ENV=production bin/rails db:migrate
RAILS_ENV=production bin/rails assets:precompile

