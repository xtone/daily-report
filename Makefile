.PHONY: help setup build up down restart logs console test clean

# デフォルトのdocker-composeファイル
DC = docker-compose -f docker-compose.dev.yml

help: ## ヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## 開発環境をセットアップ
	@./scripts/setup-dev.sh

build: ## Dockerイメージをビルド
	$(DC) build

up: ## コンテナを起動
	$(DC) up -d

down: ## コンテナを停止
	$(DC) down

restart: ## コンテナを再起動
	$(DC) restart

logs: ## ログを表示（tail -f）
	$(DC) logs -f

app-logs: ## アプリケーションのログのみ表示
	$(DC) logs -f app

db-logs: ## データベースのログのみ表示
	$(DC) logs -f db

console: ## Rails consoleを起動
	$(DC) exec app bundle exec rails console

db-console: ## MySQLコンソールを起動
	$(DC) exec db mysql -u root -ppassword daily_report_development

migrate: ## マイグレーションを実行
	$(DC) exec app bundle exec rails db:migrate

rollback: ## マイグレーションをロールバック
	$(DC) exec app bundle exec rails db:rollback

seed: ## シードデータを投入
	$(DC) exec app bundle exec rails db:seed

test: ## テストを実行
	docker-compose -f docker-compose.test.yml run --rm app-test

test-watch: ## テストを監視モードで実行
	$(DC) exec app bundle exec guard

rubocop: ## Rubocopを実行
	$(DC) exec app bundle exec rubocop

rubocop-fix: ## Rubocopで自動修正
	$(DC) exec app bundle exec rubocop -a

routes: ## ルーティングを表示
	$(DC) exec app bundle exec rails routes

bundle: ## bundle installを実行
	$(DC) exec app bundle install

yarn: ## yarn installを実行
	$(DC) exec app yarn install

webpack: ## Webpackをビルド
	$(DC) exec app ./bin/webpack

webpack-dev: ## webpack-dev-serverを起動
	$(DC) exec webpacker ./bin/webpack-dev-server

clean: ## コンテナとボリュームを削除（注意：データも削除されます）
	$(DC) down -v

attach: ## appコンテナにアタッチ
	$(DC) exec app bash

ps: ## コンテナの状態を表示
	$(DC) ps