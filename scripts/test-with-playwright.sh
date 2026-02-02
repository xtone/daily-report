#!/bin/bash

# 動作確認用スクリプト
# PR #165 (jsbundling-rails) と PR #166 (Webpacker削除) の動作確認

set -e

echo "========================================="
echo "Daily Report E2E Test Runner"
echo "========================================="

# 現在のブランチを保存
CURRENT_BRANCH=$(git branch --show-current)

# テスト対象のブランチ
BRANCHES=("feature/issue-153-implement-jsbundling-rails" "feature/issue-154-cleanup-webpacker")

for BRANCH in "${BRANCHES[@]}"; do
    echo ""
    echo "Testing branch: $BRANCH"
    echo "-----------------------------------------"
    
    # ブランチをチェックアウト
    git checkout $BRANCH
    
    # 依存関係をインストール
    echo "Installing dependencies..."
    docker-compose exec app bundle install
    docker-compose exec app yarn install
    
    # JavaScriptをビルド
    echo "Building JavaScript..."
    docker-compose exec app yarn build
    
    # Railsサーバーを再起動（バックグラウンドで）
    echo "Restarting Rails server..."
    docker-compose exec -d app bundle exec rails server -b 0.0.0.0
    
    # サーバーが起動するまで待機
    echo "Waiting for server to start..."
    sleep 10
    
    # E2Eテストを実行
    echo "Running E2E tests..."
    cd e2e
    npm install
    npx playwright install --with-deps chromium
    npm test -- --project=chromium
    
    # スクリーンショットを保存
    mkdir -p ../test-results/$BRANCH
    cp -r screenshots/* ../test-results/$BRANCH/ 2>/dev/null || true
    
    cd ..
    
    echo "Tests completed for $BRANCH"
done

# 元のブランチに戻る
git checkout $CURRENT_BRANCH

echo ""
echo "========================================="
echo "All tests completed!"
echo "Check test-results/ directory for screenshots"
echo "========================================="