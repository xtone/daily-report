FROM ruby:2.3.1
ENV LANG C.UTF-8

RUN apt-get update -qq
RUN apt-get install -y build-essential mysql-client nodejs npm && \
                       #--no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

#RUN npm cache clean
#RUN npm install n -g
#RUN n stable
#RUN ln -sf /usr/local/bin/node /usr/bin/node
#RUN apt-get purge -y nodejs npm

RUN apt-get autoremove -y

ENV APP_ROOT /daily-report
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

ADD Gemfile* $APP_ROOT/

ENV BUNDLE_GEMFILE=$APP_ROOT/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

RUN bundle install
