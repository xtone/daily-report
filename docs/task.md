# Ruby on Rails アップグレードタスクリスト

このドキュメントは、Ruby 2.4.2/Rails 5.1.7から最新版（Ruby 3.3.x/Rails 8.0）へのアップグレードに必要なタスクを記載しています。

## 前提条件

- [ ] プロジェクトのバックアップを作成する
- [ ] 既存のテストスイートが全て通ることを確認する
- [ ] Gitで全ての変更をコミットし、新しいブランチを作成する
- [ ] 本番環境のデータベースのバックアップを作成する

## 段階的アップグレード

### Phase 1: Rails 5.1 → Rails 5.2

#### 準備
- [x] Rails 5.2のアップグレードガイドを読む
- [x] Ruby 2.4.2 → Ruby 2.5.0以上にアップグレード（Rails 5.2の要件）

#### 実装
- [x] Gemfileで`gem 'rails', '~> 5.2.0'`に変更
- [x] Bootsnap gemを追加（パフォーマンス向上のため推奨）
- [x] `bundle update rails`を実行
- [x] `rails app:update`を実行し、設定ファイルを更新
- [x] credentialsへの移行（secrets.ymlから）
- [ ] Active Storageの設定を確認（既に使用している場合）
- [x] Content Security Policy（CSP）の設定を追加
- [x] deprecation warningを確認・修正

#### テスト・検証
- [x] 全てのテストが通ることを確認
- [x] アプリケーションが正常に起動することを確認
- [ ] 主要な機能を手動でテスト

### Phase 2: Rails 5.2 → Rails 6.0

#### 準備
- [x] Rails 6.0のアップグレードガイドを読む
- [x] Ruby 2.5.0 → Ruby 2.6.10にアップグレード（Rails 6.0の要件）
- [x] Node.js 8.12.0 → Node.js 12.22.12にアップグレード

#### 実装
- [x] Gemfileで`gem 'rails', '~> 6.0.0'`に変更
- [x] Webpackerを最新版にアップグレード
- [x] `bundle update rails`を実行
- [x] `rails app:update`を実行
- [x] Zeitwerkモードへの移行（autoloading）
- [x] config.hosts設定を追加
- [ ] Force SSLの設定を確認・更新
- [ ] Action Cable JavaScriptの変更に対応
- [ ] Active Storageの変更に対応
- [x] factory_girl_rails → factory_bot_railsへ移行

#### テスト・検証
- [x] 全てのテストが通ることを確認
- [x] autoloadingが正しく動作することを確認
- [x] アプリケーションが正常に起動することを確認
- [ ] JavaScript関連の機能をテスト

### Phase 3: Rails 6.0 → Rails 6.1

#### 準備
- [x] Rails 6.1のアップグレードガイドを読む
- [x] Ruby 2.5.0以上を維持

#### 実装
- [x] Gemfileで`gem 'rails', '~> 6.1.0'`に変更
- [x] `bundle update rails`を実行
- [x] `rails app:update`を実行
- [x] ActiveModel::Errorクラスの変更に対応
- [x] ActiveSupport::Callbacksの変更に対応
- [x] リダイレクトステータスコード308への対応
- [x] Image Processing gemを追加（Active Storage使用時）
- [x] config_forの戻り値の変更に対応
- [x] Webpackerの設定を最新版に更新
- [x] JavaScriptパッケージの依存関係を更新
- [x] Turbolinksの動作確認と調整
- [x] CSPの設定を確認・調整

#### テスト・検証
- [x] 全てのテストが通ることを確認
- [x] エラーハンドリングが正しく動作することを確認
- [x] JavaScript機能の動作確認
- [x] アセットパイプラインの動作確認

### Phase 4: Rails 6.1 → Rails 7.0

#### 準備
- [ ] Rails 7.0のアップグレードガイドを読む
- [ ] Ruby 2.5.0 → Ruby 2.7.0以上にアップグレード（Rails 7.0の要件）
- [ ] Node.js → Node.js 14.0以上にアップグレード

#### 実装
- [ ] Gemfileで`gem 'rails', '~> 7.0.0'`に変更
- [ ] Spring gemを削除（不要になった）
- [ ] `bundle update rails`を実行
- [ ] `rails app:update`を実行
- [ ] button_toヘルパーの変更に対応
- [ ] digest classをSHA256に変更
- [ ] 新しいキャッシュシリアライゼーションフォーマットに対応
- [ ] Active Storageのvipsプロセッサーへの変更に対応

#### フロントエンド移行（重要な引き継ぎ事項）
- [ ] **Webpackerの廃止**: Rails 7.0ではWebpackerが削除されました
- [ ] **importmap-railsの導入**: `gem 'importmap-rails'`を追加
- [ ] **Hotwireの導入**: `gem 'hotwire-rails'`を追加（Turbo + Stimulus）
- [ ] **Turbolinksの削除**: Turboに置き換え
- [ ] **JavaScriptの移行**: 
  - [ ] webpackerで管理していたJSファイルをimportmapに移行
  - [ ] `app/javascript/packs/application.js` → `app/javascript/application.js`
  - [ ] Stimulusコントローラーの設定
- [ ] **CSSの移行**:
  - [ ] `gem 'cssbundling-rails'`または`gem 'dartsass-rails'`の導入を検討
  - [ ] Sassファイルの移行
- [ ] **package.jsonの整理**: 不要なnpmパッケージの削除
- [ ] **bin/dev**スクリプトの設定（開発環境用）

#### 設定ファイルの更新
- [ ] `config/importmap.rb`の設定
- [ ] `app/views/layouts/application.html.erb`のヘルパー更新
  - [ ] `javascript_pack_tag` → `javascript_importmap_tags`
  - [ ] `stylesheet_pack_tag` → `stylesheet_link_tag`
- [ ] Procfile.devの作成（必要に応じて）

#### テスト・検証
- [ ] 全てのテストが通ることを確認
- [ ] アセットパイプラインが正しく動作することを確認
- [ ] JavaScript機能が正しく動作することを確認
- [ ] Stimulusコントローラーの動作確認
- [ ] Turboの動作確認（ページ遷移、フォーム送信等）
- [ ] CSSの読み込み確認

### Phase 5: Rails 7.0 → Rails 7.1

#### 準備
- [ ] Rails 7.1のアップグレードガイドを読む
- [ ] Ruby 2.7.0以上を維持

#### 実装
- [ ] Gemfileで`gem 'rails', '~> 7.1.0'`に変更
- [ ] `bundle update rails`を実行
- [ ] `rails app:update`を実行
- [ ] secret_key_baseファイルの変更に対応
- [ ] config.autoload_libの設定を追加
- [ ] MemCacheStore/RedisCacheStoreの接続プーリングに対応
- [ ] SQLite3の厳密モードに対応
- [ ] Rails.loggerのBroadcastLogger変更に対応
- [ ] Active Record暗号化アルゴリズムの変更に対応

#### テスト・検証
- [ ] 全てのテストが通ることを確認
- [ ] ログ出力が正しく動作することを確認

### Phase 6: Rails 7.1 → Rails 7.2

#### 準備
- [ ] Rails 7.2のアップグレードガイドを読む
- [ ] Ruby 3.0.0以上にアップグレード（Rails 7.2の推奨）

#### 実装
- [ ] Gemfileで`gem 'rails', '~> 7.2.0'`に変更
- [ ] `bundle update rails`を実行
- [ ] `rails app:update`を実行
- [ ] active_job.queue_adapterの設定を確認

#### テスト・検証
- [ ] 全てのテストが通ることを確認

### Phase 7: Rails 7.2 → Rails 8.0

#### 準備
- [x] Rails 8.0のアップグレードガイドを読む
- [x] Ruby 3.1.0 → Ruby 3.3.0以上にアップグレード（Rails 8.0の推奨）

#### 実装
- [x] Gemfileで`gem 'rails', '~> 8.0.0'`に変更
- [x] `bundle update rails`を実行
- [x] `rails app:update`を実行
- [x] 新しい機能や変更点に対応
- [x] config.assume_sslの設定確認
- [x] Propshaftアセットパイプラインの動作確認

#### テスト・検証
- [x] 全てのテストが通ることを確認
- [x] パフォーマンステストを実施
- [x] 主要機能の手動テスト

### Phase 8: Rails 8.0 新機能の導入検討

#### Solid系Gemの評価
- [x] Solid Queueの検証（データベースベースのジョブキュー）
- [x] Solid Cacheの検証（SQLiteベースのキャッシュ）
- [x] Solid Cableの検証（データベースベースのAction Cable）

#### 認証システムの検討
- [x] Rails 8.0の新しい認証ジェネレーターの評価
- [x] 既存のDevise設定との比較検討

#### デプロイメントの検討
- [x] Kamal 2.0の評価
- [x] 既存のCapistrano設定との比較

#### テスト・検証
- [x] 新機能の動作確認
- [x] 既存機能への影響確認

### Phase 9: 本格運用・最適化

#### 詳細ドキュメント
- [x] Phase 9技術ドキュメントの作成（`docs/phase9-rails8-upgrade-guide.md`）

#### 本格導入の検討
- [ ] Solid系Gemの本格導入判断
- [ ] パフォーマンス最適化の実施
- [ ] 監視・ログ設定の更新
- [ ] セキュリティ設定の見直し

#### 運用体制の整備
- [ ] 新機能に関するチーム教育
- [ ] 運用手順書の更新
- [ ] 障害対応手順の更新
- [ ] バックアップ・復旧手順の確認

#### 最終検証
- [ ] 本番環境での動作確認
- [ ] パフォーマンス監視
- [ ] ユーザーフィードバックの収集

## Gem依存関係の更新

### 必須の更新
- [x] factory_girl_rails → factory_bot_railsへ移行
- [x] mysql2を最新版に更新
- [ ] devise を Rails 8対応版に更新
- [ ] pundit を最新版に更新
- [ ] rspec-rails を最新版に更新

### 削除・置換が必要なGem
- [ ] jquery-rails（Rails 7以降では非推奨）→ Stimulus等へ移行
- [ ] coffee-rails → ES6/TypeScriptへ移行
- [ ] sass-rails → cssbundling-railsまたはDartSassへ移行
- [ ] turbolinks → Turboへ移行
- [ ] webpacker → importmap-railsまたはjsbundling-railsへ移行

### その他のGem更新
- [ ] puma を最新版に更新
- [ ] rubocop を最新版に更新し、新しいRubyの構文に対応
- [ ] その他の依存関係を更新

## インフラストラクチャの更新

### Docker環境
- [ ] Dockerfileを更新（Ruby 3.3.x、Node.js 20.x）
- [ ] docker-compose.ymlを更新
- [ ] ベースイメージをDebian Bookworm以降に更新

### CI/CD
- [ ] CircleCIの設定を更新（Ruby、Node.jsバージョン）
- [ ] テスト環境の設定を更新

### デプロイメント
- [ ] Capistrano設定を更新
- [ ] 本番環境のRubyバージョンを更新
- [ ] 本番環境のNode.jsバージョンを更新

## コードの近代化

### JavaScript/フロントエンド
- [ ] jQuery依存コードをVanilla JSまたはStimulusに書き換え
- [ ] CoffeeScriptをES6に変換
- [ ] BootstrapをBootstrap 5に更新
- [ ] アセットパイプラインの設定を更新

### Ruby/Rails
- [ ] 古いRuby構文を新しい構文に更新
- [ ] 非推奨のRails APIを置き換え
- [ ] Strong Parametersの確認・更新
- [ ] Active Recordクエリの最適化

## 最終確認

- [ ] 全てのテストが通ること
- [ ] 開発環境で全機能が動作すること
- [ ] ステージング環境でのテスト
- [ ] パフォーマンステストの実施
- [ ] セキュリティ監査の実施
- [ ] ドキュメントの更新
- [ ] チームメンバーへの変更点の共有
- [ ] 本番環境へのデプロイ計画の策定

## 注意事項

1. 各フェーズごとに必ずテストを実行し、問題がないことを確認してから次のフェーズに進む
2. 大きな変更は段階的に実施し、各段階でコミットを作成する
3. 本番環境へのデプロイは慎重に計画し、ロールバック手順を準備する
4. データベースのマイグレーションは事前にバックアップを取る
5. 外部サービスとの連携部分は特に注意深くテストする 