#!/bin/bash
set -e

echo "=== Daily Report 開発環境セットアップ ==="
echo ""

# .envファイルの作成
if [ ! -f .env ]; then
    echo "📝 .envファイルを作成しています..."
    cp .env.example .env
    echo "✅ .envファイルを作成しました"
else
    echo "ℹ️  .envファイルは既に存在します"
fi

# docker-compose.override.ymlの作成
if [ ! -f docker-compose.override.yml ]; then
    echo "📝 docker-compose.override.ymlを作成しています..."
    cp docker-compose.override.yml.example docker-compose.override.yml 2>/dev/null || true
    echo "✅ docker-compose.override.ymlを作成しました"
fi

# Dockerイメージのビルド
echo ""
echo "🏗️  Dockerイメージをビルドしています..."
docker-compose -f docker-compose.dev.yml build

# コンテナの起動
echo ""
echo "🚀 コンテナを起動しています..."
docker-compose -f docker-compose.dev.yml up -d db

# データベースの起動を待つ
echo ""
echo "⏳ データベースの起動を待っています..."
sleep 10

# データベースのセットアップ
echo ""
echo "💾 データベースをセットアップしています..."
docker-compose -f docker-compose.dev.yml run --rm app bundle exec rails db:create db:migrate

# 初期データの投入
echo ""
read -p "初期データを投入しますか？ (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📊 初期データを投入しています..."
    docker-compose -f docker-compose.dev.yml run --rm app bundle exec rails app:import_csv
fi

# アプリケーションの起動
echo ""
echo "🎯 アプリケーションを起動しています..."
docker-compose -f docker-compose.dev.yml up -d

echo ""
echo "✨ セットアップが完了しました！"
echo ""
echo "📋 アクセス情報:"
echo "  - アプリケーション: http://localhost:3000"
echo "  - Webpack Dev Server: http://localhost:3035"
echo "  - MySQL: localhost:3307 (user: root, password: password)"
echo ""
echo "🔧 便利なコマンド:"
echo "  - ログ確認: docker-compose -f docker-compose.dev.yml logs -f"
echo "  - Rails console: docker-compose -f docker-compose.dev.yml exec app bundle exec rails console"
echo "  - テスト実行: docker-compose -f docker-compose.dev.yml exec app bundle exec rspec"
echo "  - 停止: docker-compose -f docker-compose.dev.yml down"
echo ""