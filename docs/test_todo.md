# 日報管理システム テストケース TODO リスト

このドキュメントは、Railsアップグレード時の動作保証に必要なテストケースのチェックリストです。

## モデルテスト

### User モデル
- [ ] バリデーションテスト
  - [ ] name の presence
  - [ ] email の presence と uniqueness
  - [ ] password の presence と confirmation
  - [ ] began_on の presence
- [ ] Devise関連の認証機能テスト
  - [ ] ログイン機能
  - [ ] パスワード暗号化
  - [ ] Remember me機能
- [ ] アソシエーションテスト
  - [ ] has_many :reports
  - [ ] has_many :user_projects
  - [ ] has_many :projects, through: :user_projects
  - [ ] has_many :user_role_associations
  - [ ] has_many :user_roles, through: :user_role_associations
- [ ] スコープテスト
  - [ ] available スコープ（論理削除されていないユーザー）
- [ ] インスタンスメソッドテスト
  - [ ] administrator? メソッド
  - [ ] director? メソッド
  - [ ] soft_delete メソッド
  - [ ] revive メソッド
  - [ ] fill_absent メソッド（休み日の自動登録）
- [ ] クラスメソッドテスト
  - [ ] find_in_project メソッド

### Report モデル
- [ ] バリデーションテスト
  - [ ] worked_in の presence
- [ ] アソシエーションテスト
  - [ ] belongs_to :user
  - [ ] has_many :operations (autosave: true)
  - [ ] has_many :projects, through: :operations
- [ ] クラスメソッドテスト
  - [ ] find_in_month メソッド（完全なテストの実装）
  - [ ] find_in_week メソッド（完全なテストの実装）
  - [ ] submitted_users メソッド（コメントアウトされている部分の実装）
  - [ ] unsubmitted_dates メソッド
  - [ ] output_calendar メソッド（private）

### Operation モデル
- [ ] バリデーションテスト
  - [ ] workload の数値検証（0より大きく100以下）
- [ ] アソシエーションテスト
  - [ ] belongs_to :report
  - [ ] belongs_to :project
- [ ] クラスメソッドテスト
  - [ ] summary メソッド（期間集計）

### Project モデル
- [ ] バリデーションテスト
  - [ ] code の uniqueness と数値検証
  - [ ] name の presence
  - [ ] name_reading の presence と ひらがなフォーマット
- [ ] enum テスト
  - [ ] category の各値（undefined, client_shot, client_maintenance, internal, general_affairs, other）
- [ ] アソシエーションテスト
  - [ ] has_many :operations
  - [ ] has_many :user_projects
  - [ ] has_many :users, through: :user_projects
  - [ ] has_many :estimates
  - [ ] has_many :bills, through: :estimates
- [ ] スコープテスト
  - [ ] available スコープ（hidden: false）
  - [ ] order_by_reading スコープ
- [ ] クラスメソッドテスト
  - [ ] find_in_user メソッド（実装が必要）
  - [ ] next_expected_code メソッド（実装が必要）
- [ ] インスタンスメソッドテスト
  - [ ] members メソッド
  - [ ] displayed? メソッド
  - [ ] display_status メソッド

### Estimate モデル
- [ ] バリデーションテスト
  - [ ] serial_no の uniqueness
  - [ ] subject の presence
- [ ] アソシエーションテスト
  - [ ] belongs_to :project
  - [ ] has_many :bills

### Bill モデル
- [ ] バリデーションテスト
  - [ ] serial_no の uniqueness
  - [ ] subject の presence
- [ ] アソシエーションテスト
  - [ ] belongs_to :estimate

### UserProject モデル
- [ ] アソシエーションテスト
  - [ ] belongs_to :user
  - [ ] belongs_to :project
- [ ] ユニーク制約のテスト
  - [ ] user_id と project_id の組み合わせの一意性

### UserRole モデル
- [ ] アソシエーションテスト
  - [ ] has_many :user_role_associations
  - [ ] has_many :users, through: :user_role_associations
- [ ] メソッドテスト
  - [ ] administrator? メソッド
  - [ ] director? メソッド

## コントローラーテスト

### ApplicationController
- [ ] 認証前のリダイレクト
- [ ] ログイン後のリダイレクト
- [ ] set_raven_context の動作

### ReportsController
- [ ] index アクション
  - [ ] ログイン時の正常表示
  - [ ] 未ログイン時のリダイレクト
  - [ ] JSONレスポンスの検証
- [ ] show アクション
  - [ ] 正常な日報の取得
  - [ ] 権限のない日報へのアクセス制限
- [ ] new アクション
- [ ] create アクション
  - [ ] 正常な日報の作成
  - [ ] バリデーションエラー時の処理
  - [ ] 作業時間の合計が100%になることの検証
- [ ] edit アクション
- [ ] update アクション
  - [ ] 正常な更新
  - [ ] バリデーションエラー時の処理
- [ ] destroy アクション

### Reports::SummariesController
- [ ] show アクション
  - [ ] 集計データの正確性
  - [ ] 期間指定の検証

### Reports::UnsubmittedsController
- [ ] show アクション
  - [ ] 未提出日の正確な取得
  - [ ] 権限による表示制限

### ProjectsController
- [ ] index アクション
  - [ ] プロジェクト一覧の表示
  - [ ] available スコープの適用確認
- [ ] show アクション
- [ ] new アクション（管理者権限）
- [ ] create アクション
  - [ ] 正常なプロジェクト作成
  - [ ] プロジェクトコードの自動採番
- [ ] edit アクション（管理者権限）
- [ ] update アクション
  - [ ] 正常な更新
  - [ ] 権限チェック
- [ ] destroy アクション（論理削除）

### Projects::MembersController
- [ ] index アクション
  - [ ] メンバー一覧の取得
- [ ] update アクション
  - [ ] メンバーの追加・削除
- [ ] destroy アクション

### UsersController
- [ ] index アクション（管理者権限）
- [ ] show アクション
- [ ] new アクション（管理者権限）
- [ ] create アクション
  - [ ] 正常なユーザー作成
  - [ ] 権限の設定
- [ ] edit アクション
- [ ] update アクション
  - [ ] 正常な更新
  - [ ] 自分以外のユーザー編集の権限チェック
- [ ] destroy アクション（論理削除）
- [ ] revive アクション

### EstimatesController
- [ ] index アクション
  - [ ] 見積もり一覧の表示
- [ ] create アクション
  - [ ] 正常な見積もり作成
  - [ ] PDFファイルのアップロード処理
- [ ] confirm アクション

### BillsController
- [ ] index アクション
  - [ ] 請求書一覧の表示
- [ ] create アクション
  - [ ] 正常な請求書作成
  - [ ] 見積もりとの関連付け
- [ ] confirm アクション

### Settings::ProjectsController
- [ ] index アクション
  - [ ] ユーザーのプロジェクト設定表示
- [ ] update アクション
  - [ ] プロジェクトの表示/非表示切り替え

### Settings::PasswordsController
- [ ] show アクション
- [ ] update アクション
  - [ ] パスワード変更の成功
  - [ ] 現在のパスワードの検証
  - [ ] 新しいパスワードの確認

### Admin::CsvsController
- [ ] index アクション
  - [ ] CSVインポート機能

## リクエストスペック（統合テスト）

### 認証フロー
- [ ] ログイン → 日報作成 → ログアウトの一連の流れ
- [ ] セッションタイムアウトの処理
- [ ] Remember me機能の動作確認

### 日報作成フロー
- [ ] 日報の新規作成から保存まで
- [ ] 複数プロジェクトへの時間配分
- [ ] 作業時間の合計が100%でない場合のエラー処理

### 権限管理
- [ ] 一般ユーザーの操作制限
- [ ] ディレクター権限の確認
- [ ] 管理者権限の確認

## システムスペック（E2Eテスト）

### React コンポーネントとの連携
- [ ] 日報入力フォームの動的な動作
- [ ] プロジェクト選択の自動補完
- [ ] カレンダー表示の切り替え

### レポート機能
- [ ] 月次レポートの表示
- [ ] 週次レポートの表示
- [ ] 集計データのグラフ表示

## その他のテスト

### ヘルパーメソッド
- [ ] ApplicationHelper のメソッド
- [ ] 各種フォーマット用ヘルパー

### Rake タスク
- [ ] CSVインポートタスク（app:import_csv）

### API レスポンス
- [ ] JSON形式のレスポンス構造
- [ ] エラーレスポンスの形式

### セキュリティ
- [ ] SQLインジェクション対策
- [ ] XSS対策
- [ ] CSRF対策

### パフォーマンス
- [ ] N+1クエリの検出
- [ ] 大量データ処理時のレスポンス

## 優先度

### 高優先度（Railsアップグレードに必須）
1. モデルのバリデーションとアソシエーション
2. 認証・認可機能
3. 基本的なCRUD操作
4. データベーストランザクション

### 中優先度
1. 複雑なビジネスロジック（集計、レポート生成）
2. React連携部分
3. ファイルアップロード機能

### 低優先度
1. UI/UXに関するテスト
2. パフォーマンステスト
3. 詳細なエラーハンドリング

## 備考

- 既存のテストファイルには空の記述やコメントアウトされた部分が多いため、これらの実装を優先的に行う
- FactoryBotの定義は存在するので、これを活用してテストデータを作成する
- システムスペックを実装する際は、JavaScript実行環境（Capybara + Selenium等）の設定が必要
- Railsアップグレード前に最低限、高優先度のテストは実装すべき 