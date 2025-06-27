# Daily Report

社内の日報管理用システムです。

## 開発環境のセットアップ

[Docker](https://www.docker.com/)と[Docker Compose](https://docs.docker.com/compose/)を利用しています。

### 初回セットアップ

1. イメージのビルド
```
docker-compose build --no-cache
```

#### Apple Silicon Mac (M1/M2/M3) を使用している場合

Apple Silicon Macでは、以下の追加設定が必要です：

```
cp docker-compose.override.yml.example docker-compose.override.yml
```

これにより、MySQLとRailsアプリケーションがx86_64エミュレーションで動作するようになります。
Windows/Intel Mac環境では、この手順はスキップしてください。

2. コンテナの起動
```
docker-compose up -d
```

3. DBセットアップ
```
docker-compose exec app bundle exec rails db:create
docker-compose exec app bundle exec rails db:migrate
```

4. データのインポート（任意：あらかじめ、`tmp`ディレクトリに各種CSVファイルを配置してください）
```
docker-compose exec app bundle exec rails app:import_csv
```

### 開発環境の操作

Railsサーバーの起動
```
docker-compose exec app bundle exec rails server -b 0.0.0.0
```

コンテナに入る
```
docker-compose exec app bash
```

ログの確認
```
docker-compose logs -f app
```

環境の停止
```
docker-compose down
```

環境の完全削除（ボリュームも含む）
```
docker-compose down -v
```

http://localhost:3456 でアクセスできます。

## テストの実行

RSpecによるテストが用意されています。

### テストの実行方法

全テストの実行
```
docker-compose exec app bundle exec rspec
```

特定のテストファイルの実行
```
docker-compose exec app bundle exec rspec spec/models/user_spec.rb
```

特定のテストケースの実行（行番号指定）
```
docker-compose exec app bundle exec rspec spec/models/user_spec.rb:10
```

### テスト実行時の注意事項

- テストデータベースは自動的に作成されます
- テストはutf8文字セットで実行されるため、日本語データも正しく扱えます（本番環境と同じ文字セット）
- 現在、30個のテストケースがあり、13個のpendingテストが含まれています

## システム概要

このアプリケーションは、社内スタッフの日報を管理するためのシステムです。バックエンドにRuby on Rails、フロントエンドにReactを使用しています。

## 主要機能

### 1. ユーザー管理機能
- **認証機能**: Deviseを使用したログイン/ログアウト
- **ユーザー属性**:
  - 部署（営業部長、エンジニア、デザイナー、その他）
  - 権限（管理者、ディレクター）
  - 集計開始日の設定
- **論理削除**: 退職者などの非表示化と復活機能

### 2. 日報管理機能
- **日報の作成・編集・削除**
  - 勤務日ごとに日報を作成
  - 複数プロジェクトへの作業時間配分（%単位）
  - 土日祝日は自動的に除外
- **日報の表示**:
  - 月単位での表示
  - 週単位（7日分）での表示
  - カレンダー形式での表示
- **集計・分析**:
  - プロジェクト×ユーザーごとの作業時間集計
  - 期間指定での集計
- **未提出管理**: 日報未提出日の確認と通知

### 3. プロジェクト管理機能
- **プロジェクト情報**:
  - プロジェクトコード（年度＋通し番号）
  - プロジェクト名と読み仮名
  - カテゴリー分類（顧客案件、保守、内部、総務、その他）
- **メンバー管理**: プロジェクトへのユーザー割り当て
- **表示管理**: プロジェクトの表示/非表示切り替え

### 4. 見積もり・請求書管理機能
- **見積もり**:
  - プロジェクトごとの見積もり作成
  - 職種別（ディレクター、エンジニア、デザイナー、その他）の人日管理
  - 金額と原価の管理
  - PDFファイルの管理
- **請求書**:
  - 見積もりに基づく請求書作成
  - シリアル番号による管理
  - PDFファイルの管理

### 5. 管理者機能
- **CSVインポート**: 初期データの一括登録
- **ユーザー管理**: 全ユーザーの管理権限

### 6. その他の機能
- **休暇日の自動登録**: 休暇プロジェクトへの自動割り当て
- **パスワード変更**: 個人設定でのパスワード変更
- **レスポンシブUI**: ReactによるSPA（Single Page Application）実装

## データモデル

- **User**: ユーザー情報（認証、部署、権限など）
- **Report**: 日報（勤務日ごと）
- **Operation**: 作業内容（日報内のプロジェクトごとの作業時間）
- **Project**: プロジェクト情報
- **Estimate**: 見積もり情報
- **Bill**: 請求書情報
- **UserProject**: ユーザーとプロジェクトの関連
- **UserRole**: ユーザー権限
