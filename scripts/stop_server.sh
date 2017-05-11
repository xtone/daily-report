#!/bin/bash

source /etc/environment
source /home/ec2-user/.bash_profile

export PATH RAILS_ENV RAILS_HOME DB_HOST DB_USERNAME DB_PASSWORD SECRET_KEY_BASE

PIDFILE=${RAILS_HOME}/tmp/puma.pid
if [ -e ${PIDFILE} ]; then
    cd ${RAILS_HOME}
    RAILS_ENV=production bin/bundle exec pumactl -F config/puma_production.rb stop
fi
