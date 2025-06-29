FROM ruby:3.2.5
ENV LANG C.UTF-8

# 必要なパッケージをインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        ca-certificates \
        libmariadb-dev-compat \
        python3 \
        make \
        g++ && \
    rm -rf /var/lib/apt/lists/*

# Node.js 18.x をインストール（Debian標準パッケージ）
RUN apt-get update && \
    apt-get install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/* && \
    node --version && \
    npm --version

# Yarnをnpmでインストール
RUN npm install -g yarn@1.22.19

# Ruby 3.2で使用可能な最新のBundler 2.4.22をインストール
RUN gem update --system && gem install bundler -v 2.4.22

ENV APP_ROOT /daily-report
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

EXPOSE 3000
