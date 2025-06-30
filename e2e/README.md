# E2E Tests with Playwright

このディレクトリには、Daily ReportシステムのE2Eテストが含まれています。

## セットアップ

```bash
cd e2e
npm install
npx playwright install
```

## テスト実行

### 前提条件
1. Railsサーバーが起動していること
   ```bash
   docker-compose exec app bundle exec rails server -b 0.0.0.0
   ```
   
2. テスト用のユーザーが存在すること
   - 一般ユーザー: test@example.com
   - 管理者: admin@example.com

### テストの実行

```bash
# ヘッドレスモードで実行
npm test

# ブラウザを表示して実行
npm run test:headed

# UIモードで実行（インタラクティブ）
npm run test:ui

# 特定のテストファイルのみ実行
npx playwright test react-components.spec.ts
```

### コードジェネレーター

新しいテストを作成する際に便利なツール：

```bash
npm run codegen
```

## テスト結果

- スクリーンショット: `screenshots/`ディレクトリ
- テストレポート: `npm run report`で表示

## トラブルシューティング

### ログインできない場合
1. テスト用ユーザーが存在することを確認
2. `e2e/tests/react-components.spec.ts`のログイン情報を更新

### Reactコンポーネントが表示されない場合
1. JavaScriptのビルドが完了していることを確認
   ```bash
   docker-compose exec app yarn build
   ```
2. ブラウザのコンソールでエラーを確認