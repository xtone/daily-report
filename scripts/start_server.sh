#!/bin/bash

cd /home/ec2-user/daily-report
RAILS_ENV=production bin/bundle exec pumactl -F config/puma.rb start
