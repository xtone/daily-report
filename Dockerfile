FROM ruby:2.4
ENV LANG C.UTF-8

RUN apt-get update -qq && apt-get install -y apt-utils build-essential npm lsb-release apt-transport-https

# Install latest Node.js
RUN npm cache clean && npm install n -g
RUN n stable
RUN ln -sf /usr/local/bin/node /usr/bin/node
RUN apt-get purge -y nodejs npm

RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.3-1_all.deb && \
    DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.3-1_all.deb && \
    rm -f mysql-apt-config_0.8.3-1_all.deb

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && apt-get install -y mysql-client yarn

RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ENV APP_ROOT /daily-report
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

ADD Gemfile* $APP_ROOT/

ENV BUNDLE_GEMFILE=$APP_ROOT/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

#RUN bundle install
