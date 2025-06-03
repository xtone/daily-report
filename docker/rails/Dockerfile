FROM ruby:3.1.6
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

# Node.js 14.21.3を直接バイナリからインストール
RUN curl -fsSL https://nodejs.org/dist/v14.21.3/node-v14.21.3-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1 && \
    node --version && \
    npm --version

# Yarnをnpmでインストール
RUN npm install -g yarn@1.22.19

# Ruby 3.1.6に適したBundler 2.5.23をインストール
RUN gem update --system && gem install bundler -v 2.5.23

ENV APP_ROOT /daily-report
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

EXPOSE 3000

COPY Gemfile $APP_ROOT/
COPY Gemfile.lock $APP_ROOT/

ENV BUNDLE_GEMFILE=$APP_ROOT/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

# Gemfile.lockが空の場合はbundle install、そうでなければbundle update
RUN if [ -s Gemfile.lock ]; then \
        sed -i 's/BUNDLED WITH.*/BUNDLED WITH/' Gemfile.lock && \
        echo "   2.5.23" >> Gemfile.lock && \
        bundle _2.5.23_ update; \
    else \
        bundle _2.5.23_ install; \
    fi

COPY . $APP_ROOT
