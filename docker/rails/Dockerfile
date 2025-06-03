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

# Node.js 12.22.12を直接バイナリからインストール
RUN curl -fsSL https://nodejs.org/dist/v12.22.12/node-v12.22.12-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1 && \
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

COPY Gemfile $APP_ROOT/
COPY Gemfile.lock $APP_ROOT/

ENV BUNDLE_GEMFILE=$APP_ROOT/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

# Gemfile.lockが空の場合はbundle install、そうでなければbundle update
RUN if [ -s Gemfile.lock ]; then \
        sed -i 's/BUNDLED WITH.*/BUNDLED WITH/' Gemfile.lock && \
        echo "   2.4.22" >> Gemfile.lock && \
        bundle _2.4.22_ update; \
    else \
        bundle _2.4.22_ install; \
    fi

COPY . $APP_ROOT
