# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 共通開発コマンド

### Dockerベースの開発環境
このプロジェクトはDockerを使用して開発環境を構築します。

**開発環境セットアップ**
```bash
# 自動セットアップ（推奨）
./scripts/setup-dev.sh

# 手動セットアップ
make setup
# または
docker-compose -f docker-compose.dev.yml build
docker-compose -f docker-compose.dev.yml up -d
docker-compose -f docker-compose.dev.yml exec app bundle exec rails db:create
docker-compose -f docker-compose.dev.yml exec app bundle exec rails db:migrate
```

**日常的な開発コマンド**
```bash
# サーバー起動
make up

# サーバー停止
make down

# Rails console
make console

# ログ確認
make logs
make app-logs  # アプリのみ
```

### テスト実行
```bash
# 全テスト実行
make test
# または
docker-compose -f docker-compose.test.yml run --rm app-test

# 開発環境でのテスト実行
docker-compose -f docker-compose.dev.yml exec app bundle exec rspec

# 特定ファイルのテスト
docker-compose -f docker-compose.dev.yml exec app bundle exec rspec spec/models/user_spec.rb

# 特定行のテスト
docker-compose -f docker-compose.dev.yml exec app bundle exec rspec spec/models/user_spec.rb:10
```

### リント・コード品質
```bash
# Rubocop実行
make rubocop

# Rubocop自動修正
make rubocop-fix
```

### E2Eテスト
```bash
# E2Eテスト環境のセットアップ（初回のみ）
make e2e-setup

# E2Eテストの実行
make e2e-test

# スクリプトを使った実行
./scripts/run-e2e-tests.sh

# 特定のテストファイルのみ実行
docker-compose -f docker-compose.test.yml run --rm app-test bundle exec rspec spec/features/page_display_spec.rb

# テスト失敗時のスクリーンショット確認
ls -la tmp/screenshots/
```

### フロントエンド開発
```bash
# Webpackビルド（開発）
npm run build:dev

# Webpackビルド（本番）
npm run build

# Webpack監視モード
npm run watch
```

### データベース操作
```bash
# マイグレーション実行
make migrate

# マイグレーションロールバック
make rollback

# CSVデータインポート
docker-compose -f docker-compose.dev.yml exec app bundle exec rails app:import_csv
```

## プロジェクト構造

### 技術スタック
- **バックエンド**: Ruby on Rails 6.1
- **フロントエンド**: React 15.x + Webpack 3.x
- **データベース**: MySQL
- **認証**: Devise
- **認可**: Pundit
- **テンプレート**: Slim
- **CSS**: Bootstrap + SCSS
- **テスト**: RSpec + FactoryBot

### アーキテクチャの特徴

**Rails + React SPAハイブリッド**
- メインはRailsのERB/Slimテンプレート
- 動的な画面はReact SPAとして実装（`app/javascript/packs/`）
- Webpackで各画面別にJSエントリーポイントを分割

**データモデル構造**
- `User`: ユーザー（部署、権限、論理削除対応）
- `Report`: 日報（勤務日ごと）
- `Operation`: 作業内容（日報内のプロジェクト別作業時間）
- `Project`: プロジェクト（コード、カテゴリー、メンバー管理）
- `Estimate`: 見積書
- `Bill`: 請求書
- `UserProject`: ユーザー・プロジェクト関連テーブル

**認証・認可パターン**
- Deviseによるユーザー認証
- Punditによる権限制御（管理者、ディレクター権限）
- 論理削除（`deleted_at`）による非活性ユーザー管理

### 重要なディレクトリ

**Rails関連**
- `app/models/`: ActiveRecordモデル
- `app/controllers/`: コントローラー（管理者用は`admin/`配下）
- `app/policies/`: Pundit認可ポリシー
- `app/views/`: Slim/ERBテンプレート

**React関連**
- `app/javascript/packs/`: 各画面のエントリーポイント
- `app/javascript/components/`: 再利用可能なReactコンポーネント

**設定・デプロイ**
- `docker/`: Docker関連設定
- `scripts/`: 開発用スクリプト
- `config/`: Rails設定
- `lib/tasks/`: カスタムRakeタスク

## 開発時の注意点

### テスト実行時
- テストデータベースは自動作成
- 30テストケース中13個がpending状態
- utf8文字セットで日本語データも適切に処理

### フロントエンド開発時
- React 15.x（古いバージョン）を使用
- Webpack 3.xでビルド
- ハッシュ付きファイル名で本番キャッシュ対応

### Docker環境
- Apple Silicon Mac使用時は`docker-compose.override.yml`が必要
- 開発環境は`docker-compose.dev.yml`を使用
- 本番環境は`docker-compose.yml`を使用

### Rake タスク
- `rails app:import_csv`: 旧システムからのデータ移行
- `rails app:unsubmitted_notification_slack`: 未提出日報のSlack通知
- `rails app:give_administrator_role_to[email]`: 管理者権限付与

## アップグレード作業時の重要事項

### RailsやReactアップデート時の確認事項
RailsやReactなどの主要ライブラリをアップデートする際は、以下の手順で動作確認を行ってください：

1. **単体テストの実行**
   ```bash
   make test
   ```

2. **E2Eテストの実行**
   ```bash
   make e2e-test
   ```

3. **リントチェック**
   ```bash
   make rubocop
   ```

### タスク完了条件
以下のすべてが成功することが、アップグレードタスクの完了条件です：

- [ ] すべての単体テスト（RSpec）がパスすること
- [ ] すべてのE2Eテスト（Capybara）がパスすること
- [ ] Rubocopによるコード品質チェックがパスすること
- [ ] 開発環境でアプリケーションが正常に起動すること

### E2Eテストの内容
E2Eテストでは以下のページの表示と動作を確認します：

- ログイン画面の表示
- 日報一覧（ホーム画面）
- プロジェクト管理画面
- ユーザー管理画面（管理者）
- 設定画面（プロジェクト設定、パスワード変更）
- 管理画面（管理者ダッシュボード、CSV出力）
- JavaScriptエラーがないこと
- レスポンシブデザインの動作

### トラブルシューティング
- E2Eテストが失敗した場合は `tmp/screenshots/` にスクリーンショットが保存されます
- Chrome関連のエラーが出る場合は `make e2e-setup` を実行してください

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.