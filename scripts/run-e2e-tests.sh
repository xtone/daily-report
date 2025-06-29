#!/bin/bash
set -e

echo "=== E2E テストの実行 ==="
echo ""

# スクリーンショット用ディレクトリを作成
mkdir -p tmp/screenshots

# テスト環境でGemをインストール
echo "📦 Gemをインストール中..."
docker-compose -f docker-compose.test.yml run --rm app-test bundle install

# データベースをセットアップ
echo ""
echo "💾 データベースをセットアップ中..."
docker-compose -f docker-compose.test.yml run --rm app-test bundle exec rails db:create db:migrate RAILS_ENV=test

# E2Eテストを実行
echo ""
echo "🧪 E2Eテストを実行中..."
docker-compose -f docker-compose.test.yml run --rm \
  -e RAILS_ENV=test \
  app-test bundle exec rspec spec/features --format documentation

echo ""
echo "✅ E2Eテストが完了しました！"

# スクリーンショットがある場合は通知
if [ -n "$(ls -A tmp/screenshots 2>/dev/null)" ]; then
  echo ""
  echo "📸 スクリーンショットが保存されています: tmp/screenshots/"
fi