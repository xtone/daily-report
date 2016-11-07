FROM ruby:2.3.1
ENV LANG C.UTF-8

RUN apt-get update -qq && \
    apt-get install -y build-essential mysql-client nodejs \
                       --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

ENV APP_ROOT /daily-report
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

ADD Gemfile* $APP_ROOT/

ENV BUNDLE_GEMFILE=$APP_ROOT/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

RUN bundle install

ADD . $APP_ROOT
