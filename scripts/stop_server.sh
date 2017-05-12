#!/bin/bash

PIDFILE=${RAILS_HOME}/tmp/pids/puma.pid
if [ -e ${PIDFILE} ]; then
    cd ${RAILS_HOME}
    RAILS_ENV=production bin/bundle exec pumactl -F config/puma.rb stop
fi
