FROM ruby:2.7.8
ENV LANG C.UTF-8

# 必要なパッケージをインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        ca-certificates \
        libmariadb-dev-compat \
        python \
        make \
        g++ && \
    rm -rf /var/lib/apt/lists/*

# Node.js 14.x をNodeSourceリポジトリからインストール（node-sass 4.14.1との互換性確保）
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    node --version && \
    npm --version

# Yarnをnpmでインストール
RUN npm install -g yarn@1.22.19

# Ruby 2.7で使用可能な最新のBundler 2.4.22をインストール
RUN gem update --system 3.4.22 && gem install bundler -v 2.4.22

ENV APP_ROOT /daily-report
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

EXPOSE 3000
