# 開発環境セットアップガイド

このドキュメントでは、Daily Reportアプリケーションの開発環境をDocker Composeを使って構築する手順を説明します。

## 前提条件

- Docker Desktop for Mac/Windows または Docker Engine (Linux)
- Docker Compose v1.27.0以上
- Git

## クイックスタート

```bash
# リポジトリをクローン
git clone https://github.com/xtone/daily-report.git
cd daily-report

# 開発環境をセットアップ
./scripts/setup-dev.sh
```

## 手動セットアップ

### 1. 環境変数の設定

```bash
cp .env.example .env
```

必要に応じて`.env`ファイルを編集してください。

### 2. Dockerイメージのビルド

```bash
docker-compose -f docker-compose.dev.yml build
```

### 3. データベースの起動

```bash
docker-compose -f docker-compose.dev.yml up -d db
```

### 4. データベースのセットアップ

```bash
docker-compose -f docker-compose.dev.yml run --rm app bundle exec rails db:create db:migrate
```

### 5. 初期データの投入（オプション）

```bash
docker-compose -f docker-compose.dev.yml run --rm app bundle exec rails app:import_csv
```

### 6. アプリケーションの起動

```bash
docker-compose -f docker-compose.dev.yml up
```

## アクセス情報

- **アプリケーション**: http://localhost:3000
- **Webpack Dev Server**: http://localhost:3035
- **MySQL**: localhost:3307
  - ユーザー名: root
  - パスワード: password
  - データベース名: daily_report_development

## 開発時の便利なコマンド

### ログの確認

```bash
# すべてのログを確認
docker-compose -f docker-compose.dev.yml logs -f

# 特定のサービスのログを確認
docker-compose -f docker-compose.dev.yml logs -f app
```

### Rails console

```bash
docker-compose -f docker-compose.dev.yml exec app bundle exec rails console
```

### データベースコンソール

```bash
docker-compose -f docker-compose.dev.yml exec db mysql -u root -ppassword daily_report_development
```

### テストの実行

```bash
# すべてのテストを実行
docker-compose -f docker-compose.dev.yml exec app bundle exec rspec

# 特定のテストを実行
docker-compose -f docker-compose.dev.yml exec app bundle exec rspec spec/models/user_spec.rb
```

### マイグレーション

```bash
# マイグレーションの実行
docker-compose -f docker-compose.dev.yml exec app bundle exec rails db:migrate

# マイグレーションのロールバック
docker-compose -f docker-compose.dev.yml exec app bundle exec rails db:rollback
```

### Gemの追加

```bash
# Gemfileを編集後
docker-compose -f docker-compose.dev.yml exec app bundle install
```

### npm/Yarnパッケージの追加

```bash
# package.jsonを編集後
docker-compose -f docker-compose.dev.yml exec app yarn install
```

### コンテナの操作

```bash
# コンテナの起動
docker-compose -f docker-compose.dev.yml up -d

# コンテナの停止
docker-compose -f docker-compose.dev.yml down

# コンテナの再起動
docker-compose -f docker-compose.dev.yml restart

# コンテナとボリュームの削除（データも削除されます）
docker-compose -f docker-compose.dev.yml down -v
```

## トラブルシューティング

### ポートが使用中の場合

`docker-compose.dev.yml`でポート番号を変更できます：

```yaml
services:
  app:
    ports:
      - "3001:3000"  # 3000の代わりに3001を使用
```

### 権限エラーが発生する場合

ボリュームの権限問題が発生した場合は、以下のコマンドで修正できます：

```bash
docker-compose -f docker-compose.dev.yml exec app chown -R $(id -u):$(id -g) .
```

### データベース接続エラー

データベースが完全に起動するまで時間がかかることがあります。以下のコマンドで確認できます：

```bash
docker-compose -f docker-compose.dev.yml exec db mysqladmin ping -h localhost -u root -ppassword
```

### Webpackerのコンパイルエラー

node_modulesを再インストールしてみてください：

```bash
docker-compose -f docker-compose.dev.yml exec app rm -rf node_modules
docker-compose -f docker-compose.dev.yml exec app yarn install
```

## VSCode/RubyMine設定

### VSCode

`.vscode/settings.json`に以下を追加：

```json
{
  "ruby.pathToBundler": "docker-compose -f docker-compose.dev.yml exec -T app bundle",
  "ruby.useBundler": true,
  "solargraph.useBundler": true,
  "solargraph.commandPath": "docker-compose -f docker-compose.dev.yml exec -T app solargraph"
}
```

### RubyMine

1. Settings > Build, Execution, Deployment > Docker
2. Docker Composeファイルとして`docker-compose.dev.yml`を指定
3. Ruby SDK設定でDockerコンテナ内のRubyを指定

## 開発フロー

1. featureブランチを作成
2. 開発環境で変更を実施
3. テストを実行して確認
4. コミット・プッシュ
5. プルリクエストを作成

## 参考リンク

- [Docker Compose公式ドキュメント](https://docs.docker.com/compose/)
- [Rails Docker化ベストプラクティス](https://docs.docker.com/samples/rails/)