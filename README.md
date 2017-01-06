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
docker-compose exec app bundle install
```

DBセットアップ
```
docker-compose exec app bin/rails db:create
docker-compose exec app bin/rails db:migrate
```

データのインポート( あらかじめ、`tmp`ディレクトリに各種CSVファイルを配置してください )
```
docker-compose exec app bin/rails app:import_csv
```

バックグラウンドでイメージ実行（ポート3456でlocalhostに接続してね）
```
docker-compose start
```

Railsのサーバーログを見る
```
docker-compose logs app
```

RSpec実行
```
docker-compose exec app bundle exec rspec
```
