# Rails 7.0アップグレード チェックリスト

## 前提条件確認 ✅

- [x] Rails 6.1.7.10（最新パッチバージョン）
- [x] Ruby 2.7.8（Rails 7.0対応）
- [x] テストスイート実行可能（400例中307例動作）
- [x] deprecation warning確認済み
- [x] 主要gem互換性確認済み

## Phase 1: 依存関係の更新 ✅

- [x] puma 3.12.6 → 5.6.9（セキュリティ修正）
- [x] devise 4.9.4（4.8.1以上、Rails 7対応済み）
- [x] nokogiri 1.15.7（制約により現バージョン維持）

## Phase 2: Rails 7.0アップグレード準備

### 設定ファイルの準備
- [ ] config/application.rb の Rails 7.0設定追加
- [ ] config/environments/*.rb の新設定項目確認
- [ ] config/initializers の互換性確認

### アセット管理の確認
- [x] jsbundling-rails設定確認済み
- [x] Webpack設定動作確認済み
- [x] CSS/JavaScript ビルドプロセス検証済み

## Phase 3: Rails 7.0実装準備

### Gemfile更新準備
```ruby
# Rails本体
gem 'rails', '~> 7.0.0'

# 互換性のためのgem追加
gem 'net-smtp', require: false
gem 'net-imap', require: false  
gem 'net-pop', require: false
```

### 新機能の準備
- [ ] Zeitwerk autoloader設定確認
- [ ] Action Text / Action Mailbox使用検討
- [ ] Hotwire (Turbo/Stimulus) 移行検討

## Phase 4: 破壊的変更への対応

### Active Support
- [ ] `ActiveSupport::Dependencies`の変更対応
- [ ] autoloading動作確認

### Action Pack  
- [ ] CSRFトークン処理の確認
- [ ] Strong Parameters動作確認

### Active Record
- [ ] クエリメソッドの変更確認
- [ ] バリデーション動作確認

## Phase 5: テスト対応

### 失敗テストの修正
- [ ] ProjectsController関連テスト（1件）
- [ ] その他33件の失敗テスト修正

### Rails 7.0固有調整
- [ ] テストヘルパーの更新
- [ ] FactoryBot設定の確認
- [ ] Capybara設定の更新

## Phase 6: 動作確認

### ローカル環境
- [ ] 開発サーバー起動確認
- [ ] JavaScriptビルド確認  
- [ ] CSS/アセットパイプライン確認
- [ ] データベース操作確認

### CI/CD
- [ ] GitHub Actions動作確認
- [ ] テスト実行確認
- [ ] E2Eテスト確認

## リスクマトリックス

| 項目 | リスク | 対策 |
|------|--------|------|
| autoloading変更 | 低 | Zeitwerk使用済み |
| CSRF処理変更 | 中 | テストで検証 |
| gem互換性 | 低 | 主要gem確認済み |
| JavaScript処理 | 低 | jsbundling-rails使用 |
| テスト失敗 | 中 | 段階的修正 |

## ロールバック手順

1. **緊急時**: Gemfile.lockを直前バージョンに戻し `bundle install`
2. **データベース**: `rails db:rollback` でマイグレーション巻き戻し
3. **デプロイ**: Blue-Greenデプロイでの即座切り戻し
4. **設定**: Git revertで設定ファイル復元

## 成功指標

- [ ] 全テストが実行可能（pendingは除く）
- [ ] 開発環境での正常動作
- [ ] CI/CDの成功
- [ ] E2Eテストの成功
- [ ] パフォーマンス劣化なし

## 推定工数

| フェーズ | 工数 | 備考 |
|----------|------|------|
| Phase 2 | 0.5日 | 設定準備 |
| Phase 3 | 1日 | Rails本体アップグレード |
| Phase 4 | 1日 | 破壊的変更対応 |
| Phase 5 | 2日 | テスト修正 |
| Phase 6 | 1日 | 動作確認 |

**合計**: 5.5日