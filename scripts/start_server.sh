#!/bin/bash

cd /home/ec2-user/daily-report
RAILS_ENV=production bin/bundle exec pumactl -P tmp/puma.pid -F config/puma_production.rb start
