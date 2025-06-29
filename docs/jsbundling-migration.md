# jsbundling-rails移行ガイド

## 概要
このドキュメントは、Webpackerからjsbundling-railsへの移行手順と変更点を説明します。

## 主な変更点

### 1. 依存関係の更新
- **削除**: `gem 'webpacker'`
- **追加**: `gem 'jsbundling-rails'`
- **npm packages**: Babel 7、Webpack 5へアップグレード

### 2. ディレクトリ構造の変更
- **旧**: `/public/packs/` （Webpacker）
- **新**: `/app/assets/builds/` （jsbundling-rails）

### 3. ビルドコマンドの変更
```bash
# 開発環境
bin/dev  # Railsサーバーとwebpack watchを同時起動

# 本番ビルド
yarn build

# 開発ビルド（watchモード）
yarn dev
```

### 4. ビューファイルの変更
```slim
# 変更前
= javascript_pack_tag 'reports'

# 変更後
= javascript_include_tag 'reports'
```

## 開発ワークフロー

### 開発時
```bash
# Dockerコンテナ内で
docker-compose exec app bin/dev
```

### 本番デプロイ時
```bash
# アセットのプリコンパイル
bundle exec rails assets:precompile
```

## トラブルシューティング

### JavaScriptが読み込まれない場合
1. `app/assets/builds/`にファイルが生成されているか確認
2. `config/initializers/assets.rb`でプリコンパイル設定を確認
3. ブラウザのキャッシュをクリア

### ビルドが失敗する場合
1. `node_modules`を削除して再インストール
   ```bash
   rm -rf node_modules
   yarn install
   ```
2. webpack.config.jsの設定を確認

## 移行のメリット
- Railsの標準的なアセット管理との統合
- ビルドプロセスの簡素化
- Rails 7への移行準備
- マニフェスト管理の自動化