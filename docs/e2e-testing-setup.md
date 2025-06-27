# E2Eテスト環境セットアップガイド

## 概要
このドキュメントでは、Playwrightを使用したE2Eテスト環境のセットアップ方法と、PR #165、#166の動作確認手順を説明します。

## 必要な環境
- Docker & Docker Compose
- Node.js 18以上
- Playwright対応ブラウザ

## セットアップ手順

### 1. テスト環境の準備

```bash
# E2Eテストディレクトリに移動
cd e2e

# 依存関係をインストール
npm install

# Playwrightブラウザをインストール
npx playwright install
```

### 2. テスト用データの準備

```bash
# Dockerコンテナで実行
docker-compose exec app rails console

# テスト用ユーザーを作成
User.create!(
  email: 'test@example.com',
  password: 'password',
  name: 'テストユーザー',
  division: 'engineer'
)

User.create!(
  email: 'admin@example.com',
  password: 'password',
  name: '管理者',
  division: 'director',
  admin: true
)
```

## PR動作確認手順

### 手動での確認

1. **PR #165 (jsbundling-rails実装) の確認**
   ```bash
   git checkout feature/issue-153-implement-jsbundling-rails
   docker-compose exec app bundle install
   docker-compose exec app yarn install
   docker-compose exec app yarn build
   docker-compose exec app bundle exec rails server -b 0.0.0.0
   ```

2. **ブラウザで動作確認**
   - http://localhost:3456 にアクセス
   - 各画面でReactコンポーネントが正しく表示されることを確認

3. **E2Eテストの実行**
   ```bash
   cd e2e
   npm run test:headed
   ```

### 自動確認スクリプト

```bash
# 両方のPRを自動的にテスト
./scripts/test-with-playwright.sh
```

## 確認ポイント

### JavaScript機能
- [ ] 日報画面のカレンダーが表示される
- [ ] プロジェクト一覧でクリック操作が動作する
- [ ] 日付ピッカーが正しく動作する
- [ ] Reactコンポーネントのイベントが正しく処理される

### ビルドプロセス
- [ ] `yarn build`が正常に完了する
- [ ] app/assets/builds/にファイルが生成される
- [ ] エラーやWarningが出力されない

### パフォーマンス
- [ ] ページロード時間が許容範囲内
- [ ] JavaScriptエラーがコンソールに出力されない

## トラブルシューティング

### Playwrightが起動しない場合
```bash
# 依存関係を再インストール
npx playwright install --with-deps
```

### テストが失敗する場合
1. スクリーンショットを確認: `e2e/screenshots/`
2. テストレポートを表示: `cd e2e && npm run report`
3. ログを確認: `docker-compose logs -f app`

## スクリーンショット比較

テスト実行後、`test-results/`ディレクトリに各ブランチのスクリーンショットが保存されます。
これらを比較して、UIに意図しない変更がないことを確認してください。