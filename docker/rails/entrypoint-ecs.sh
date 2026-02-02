#!/bin/bash
set -e

echo "=== Starting ECS entrypoint script ==="

# PIDファイルを削除（前回のプロセスが残っている場合に備えて）
rm -f tmp/pids/server.pid

# データベース接続を待機
echo "Waiting for database connection..."
MAX_RETRIES=30
RETRY_COUNT=0

until bundle exec rails runner "ActiveRecord::Base.connection" 2>/dev/null; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "ERROR: Could not connect to database after $MAX_RETRIES attempts"
    exit 1
  fi
  echo "Database not ready yet... (attempt $RETRY_COUNT/$MAX_RETRIES)"
  sleep 2
done

echo "Database connection established!"

# マイグレーション実行（SKIP_DB_MIGRATE=trueで無効化可能）
if [ "$SKIP_DB_MIGRATE" != "true" ]; then
  echo "Running database migrations..."
  bundle exec rails db:migrate

  # Solid Queue用のキューデータベースマイグレーション
  echo "Running queue database migrations..."
  bundle exec rails db:migrate:queue

  # Solid Cable用のケーブルデータベースセットアップ
  echo "Setting up cable database..."
  bundle exec rails db:prepare:cable

  echo "Migrations completed!"
else
  echo "Skipping migrations (SKIP_DB_MIGRATE=true)"
fi

echo "=== Starting Rails server ==="

# 渡されたコマンドを実行（デフォルトはRailsサーバー起動）
exec "$@"
