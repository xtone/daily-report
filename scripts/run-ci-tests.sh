#!/bin/bash
set -e

echo "==================== CI環境でE2Eテストを実行 ===================="
echo "GitHub Actionsと同等の環境でテストを実行します"
echo ""
echo "環境:"
echo "  - Ubuntu 22.04"
echo "  - Ruby 3.2.5 (rbenv経由)"
echo "  - Node.js 14"
echo "  - MySQL 5.7"
echo "  - Google Chrome (Chromiumではない)"
echo "  - CI=true, HEADLESS=true"
echo ""
echo "=================================================================="

# CI環境のクリーンアップ
echo "既存のCI環境をクリーンアップ中..."
docker-compose -f docker-compose.ci.yml down -v || true

# Dockerイメージのビルド
echo ""
echo "CI環境用Dockerイメージをビルド中..."
docker-compose -f docker-compose.ci.yml build

# テストの実行
echo ""
echo "E2Eテストを実行中..."
docker-compose -f docker-compose.ci.yml run --rm app-ci

# 実行結果の取得
EXIT_CODE=$?

# クリーンアップ
echo ""
echo "CI環境をクリーンアップ中..."
docker-compose -f docker-compose.ci.yml down

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ E2Eテストが成功しました！"
else
    echo ""
    echo "❌ E2Eテストが失敗しました"
    echo "詳細なログを確認するには以下のコマンドを実行してください:"
    echo "  make ci-logs"
    echo ""
    echo "スクリーンショットを確認するには:"
    echo "  ls -la tmp/screenshots/"
fi

exit $EXIT_CODE