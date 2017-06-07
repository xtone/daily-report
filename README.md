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
docker-compose run app bin/bundle install
```

コンテナ立ち上げ
```
docker-compose start
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

Railsのサーバーログを見る
```
docker-compose logs app
```

RSpec実行
```
docker-compose exec app bin/bundle exec rspec
```

http://localhost:3456 でアクセスできます。
