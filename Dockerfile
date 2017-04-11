FROM ruby:2.4
ENV LANG C.UTF-8

RUN apt-get update -qq
RUN apt-get install -y build-essential nodejs npm lsb-release

RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.3-1_all.deb && \
    DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.3-1_all.deb && \
    rm -f mysql-apt-config_0.8.3-1_all.deb

RUN apt-get update -qq && apt-get install -y mysql-client

#RUN npm cache clean
#RUN npm install n -g
#RUN n stable
#RUN ln -sf /usr/local/bin/node /usr/bin/node
#RUN apt-get purge -y nodejs npm

RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ENV APP_ROOT /daily-report
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

ADD Gemfile* $APP_ROOT/

ENV BUNDLE_GEMFILE=$APP_ROOT/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

#RUN bundle install
