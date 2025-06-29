# Rails 7.0 アップグレード計画

## 概要
このドキュメントは、Daily ReportシステムをRails 6.1から7.0へアップグレードするための計画書です。

## 前提条件

### 現在の環境
- Rails: 6.1.7.10
- Ruby: 2.7.8
- MySQL: 5.7
- Node.js: 14.x

### アップグレード後の環境
- Rails: 7.0.x
- Ruby: 3.1.6
- MySQL: 5.7（変更なし）
- Node.js: 14.x（変更なし）

## 準備作業（このPRで対応）

### 1. Ruby バージョンアップグレード
- [x] Ruby 2.7.8 → 3.1.6へのアップグレード
- [x] `.ruby-version`ファイルの作成
- [x] Dockerファイルの更新
  - [x] Dockerfile.dev
  - [x] Dockerfile
  - [x] Dockerfile.test
- [x] GitHub Actionsの更新
  - [x] test.yml
  - [x] rubocop.yml
  - [x] e2e-test.yml
  - [x] security.yml

### 2. 依存関係の確認
- 主要gemのRails 7.0互換性確認済み
  - devise (4.9.4) - 互換性あり
  - pundit (2.5.0) - 互換性あり
  - slim-rails (3.7.0) - 互換性あり
  - jsbundling-rails (1.3.1) - 互換性あり

### 3. テストスイートの確認
- 現在のテスト結果: 400 examples, 0 failures, 60 pending
- E2Eテストも正常に動作

## 次のステップ（別PR）

### Issue #157: Rails 7.0へのアップグレード実装
1. Gemfileの更新
2. bundle updateの実行
3. rails app:updateの実行
4. 設定ファイルのコンフリクト解決
5. 新しいデフォルト設定の確認と適用

### Issue #158: Rails 7.0固有の変更対応
1. Zeitwerk autoloaderへの完全移行
2. button_toヘルパーの対応
3. CSRFトークンの扱いの変更確認
4. その他の破壊的変更への対応

## リスクと対策

### リスク
1. Ruby 3.1での非互換性
2. gem依存関係の問題
3. 実行時のパフォーマンス変化

### 対策
1. 全テストスイートでの動作確認
2. ステージング環境での十分なテスト
3. 段階的なリリース

## ロールバック計画
問題が発生した場合は、以下の手順でロールバック：
1. git revertでコミットを戻す
2. Dockerイメージを前のバージョンに戻す
3. bundle installで依存関係を復元

## 成功基準
- [ ] 全ての単体テストがパス
- [ ] 全てのE2Eテストがパス
- [ ] Rubocopチェックがパス
- [ ] 開発環境での動作確認
- [ ] ステージング環境での動作確認