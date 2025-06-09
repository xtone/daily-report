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
- [x] Rails 7.0のアップグレードガイドを読む
- [x] Ruby 2.5.0 → Ruby 2.7.0以上にアップグレード（Rails 7.0の要件）
- [x] Node.js → Node.js 14.0以上にアップグレード

#### 実装
- [x] Gemfileで`gem 'rails', '~> 7.0.0'`に変更
- [x] Spring gemを削除（不要になった）
- [x] `bundle update rails`を実行
- [x] `rails app:update`を実行
- [x] button_toヘルパーの変更に対応
- [x] digest classをSHA256に変更
- [x] 新しいキャッシュシリアライゼーションフォーマットに対応
- [x] Active Storageのvipsプロセッサーへの変更に対応

#### フロントエンド移行（jsbundling-railsへの段階的移行）
**注意**: いきなりimportmapやHotwireへの移行は変更箇所が大きいため、まずjsbundling-railsへの移行を行う

##### Step 1: jsbundling-railsの導入
- [x] **jsbundling-railsの追加**: `gem 'jsbundling-rails'`をGemfileに追加
- [x] **バンドラーの選択**: esbuild、rollup、webpackから選択（推奨: esbuild）
- [x] **インストール**: `bundle install && bin/rails javascript:install:esbuild`を実行

##### Step 2: 既存のWebpackerからの移行
- [x] **JavaScriptファイルの移動**: `app/javascript/packs/application.js`の内容を`app/javascript/application.js`に移動
- [x] **package.jsonの更新**: webpacker関連の依存関係を削除
- [x] **ビューファイルの更新**: `javascript_pack_tag`を`javascript_include_tag`に変更
- [x] **Webpackerの削除**: `gem 'webpacker'`をGemfileから削除、設定ファイルを削除

##### Step 3: cssbundling-railsの導入（推奨）
- [x] **cssbundling-railsの追加**: `gem 'cssbundling-rails'`をGemfileに追加
- [x] **Sassの設定**: `bin/rails css:install:sass`を実行
- [x] **既存SCSSファイルの移行**: 既存のスタイルシートを新しい構造に移行

##### Step 4: 開発環境の設定
- [x] **Procfile.devの作成**:
  ```
  web: bin/rails server -p 3000
  js: yarn build --watch
  css: yarn build:css --watch
  ```
- [x] **bin/devスクリプトの設定**: 開発時の自動ビルド用
- [x] **package.jsonのscriptsセクション更新**:
  ```json
  {
    "scripts": {
      "build": "esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds",
      "build:css": "sass ./app/assets/stylesheets/application.scss ./app/assets/builds/application.css"
    }
  }
  ```

##### Step 5: Webpackerの削除
- [x] **Gemfileからwebpackerを削除**
- [x] **webpacker関連ファイルの削除**:
  - [x] `config/webpack/`ディレクトリ
  - [x] `config/webpacker.yml`
  - [x] `bin/webpack`、`bin/webpack-dev-server`
- [x] **yarn.lockの更新**: `yarn install`を実行

##### Step 6: Turbolinksの段階的移行（オプション）
- [ ] **Turbolinksの継続使用**: 当面はそのまま使用可能
- [ ] **将来的なTurbo移行の準備**:
  - [ ] Turbolinks固有のイベントハンドラーを確認
  - [ ] 段階的にTurboに移行する計画を策定

#### テスト・検証
- [x] 全てのテストが通ることを確認
- [x] **jsbundling-railsの動作確認**:
  - [ ] `yarn build`でJavaScriptが正しくビルドされることを確認
  - [ ] `yarn build:css`でCSSが正しくビルドされることを確認
  - [ ] 開発環境で`bin/dev`が正常に動作することを確認
- [ ] **アセットの読み込み確認**:
  - [ ] JavaScriptファイルが正しく読み込まれることを確認
  - [ ] CSSファイルが正しく読み込まれることを確認
  - [ ] ソースマップが正しく生成されることを確認
- [ ] **既存JavaScript機能の動作確認**:
  - [ ] jQuery依存のコードが正常に動作することを確認
  - [ ] Turbolinks（継続使用時）の動作確認
  - [ ] フォーム送信、Ajax処理の動作確認
  - [ ] 既存のJavaScriptライブラリの動作確認
- [ ] **パフォーマンス確認**:
  - [ ] バンドルサイズの確認
  - [ ] ページ読み込み速度の確認
  - [ ] 開発時のビルド速度の確認

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
- [ ] **webpacker → jsbundling-railsへ移行**（Phase 4で実施）
- [ ] **sass-rails → cssbundling-railsへ移行**（Phase 4で実施、オプション）
- [ ] coffee-rails → ES6/TypeScriptへ移行（jsbundling-rails移行後に実施）
- [ ] jquery-rails（当面継続使用可能、将来的にStimulus等への移行を検討）
- [ ] turbolinks（当面継続使用可能、将来的にTurboへの移行を検討）

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
- [ ] **jsbundling-railsへの移行完了後の最適化**:
  - [ ] CoffeeScriptをES6に変換
  - [ ] 不要なJavaScriptライブラリの削除
  - [ ] バンドルサイズの最適化
- [ ] **将来的な移行の検討**:
  - [ ] jQuery依存コードをVanilla JSまたはStimulusに書き換え（段階的に実施）
  - [ ] TurbolinksからTurboへの移行（段階的に実施）
- [ ] **UI/UXの更新**:
  - [ ] BootstrapをBootstrap 5に更新
  - [ ] レスポンシブデザインの改善

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