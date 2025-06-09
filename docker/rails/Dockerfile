FROM ruby:3.0.7
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

# Node.js 18.x をNodeSourceリポジトリからインストール（esbuild対応）
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    node --version && \
    npm --version

# Yarnをnpmでインストール
RUN npm install -g yarn@1.22.19

# Ruby 3.0で使用可能なBundlerをインストール
RUN gem install bundler

ENV APP_ROOT /daily-report
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

EXPOSE 3000
