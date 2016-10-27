# Daily Report

社内の日報管理用システムです。

## 開発環境のセットアップ

[Docker](https://www.docker.com/)を利用しています。

イメージのビルド
```
docker-compose build
```

bundle install
```
docker-compose run app bundle install
```

DBセットアップ
```
docker-compose run app bundle exec rake db:create
docker-compose run app bundle exec rake db:migrate
```

バックグラウンドでイメージ実行（ポート6000でlocalhostに接続してね）
```
docker-compose up -d
```

サーバーログを見る
```
docker-compose logs app
```

RSpec実行
```
docker-compose run app bundle exec rspec
```
