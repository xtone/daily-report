# Webpacker → jsbundling-rails 移行チェックリスト

## 事前確認

- [x] 現在のJavaScript構成の調査完了
- [x] エントリーポイントの一覧作成
- [x] 依存関係の確認
- [x] CSS/画像アセットの処理方法確認
- [ ] バックアップの作成
- [ ] 開発環境での動作確認環境準備

## 移行作業

### 1. 設定ファイルの確認
- [ ] webpack.config.jsの内容確認
- [ ] package.jsonの依存関係確認
- [ ] config/webpacker.yml（既に使用していない）
- [ ] マニフェスト生成スクリプトの確認

### 2. ビューファイルの調査
- [ ] javascript_pack_tagの使用箇所一覧
- [ ] stylesheet_pack_tagの使用確認（使用なし）
- [ ] image_pack_tagの使用確認（使用なし）

### 3. テスト環境の準備
- [ ] テストデータの準備
- [ ] テストシナリオの作成
- [ ] パフォーマンス測定基準の設定

## 確認済み事項

### アセット処理
- CSS: Rails Asset Pipeline（Sprockets）で処理 ✓
- 画像: Rails Asset Pipeline（Sprockets）で処理 ✓
- JavaScript: 独自のWebpack設定でバンドル ✓

### エントリーポイント（9個）
1. application.js ✓
2. admin.jsx ✓
3. bills.jsx ✓
4. estimates.jsx ✓
5. forms.jsx ✓
6. project_list.jsx ✓
7. project_members.jsx ✓
8. reports.jsx ✓
9. reports_summary.jsx ✓
10. unsubmitted.jsx ✓

### リスク評価
- 低リスク: CSS/画像処理（既にAsset Pipeline） ✓
- 中リスク: 複数エントリーポイント、マニフェスト生成 ✓
- 高リスク: React 15.5.4の古さ ✓

## 次のアクション
1. バックアップ作成
2. 移行実装（Issue #153）へ進む