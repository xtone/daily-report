# 日報管理システム テストケース TODO リスト

このドキュメントは、Railsアップグレード時の動作保証に必要なテストケースのチェックリストです。

## モデルテスト

### User モデル
- [x] バリデーションテスト
  - [x] name の presence
  - [x] email の presence と uniqueness
  - [x] password の presence
  - [x] began_on の presence
- [x] Devise認証機能
  - [x] パスワード暗号化
  - [x] rememberable機能
- [x] アソシエーションテスト
  - [x] has_many :reports
  - [x] has_many :user_projects
  - [x] has_many :projects, through: :user_projects
  - [x] has_many :user_role_associations
  - [x] has_many :user_roles, through: :user_role_associations
- [x] スコープテスト
  - [x] available スコープ（論理削除されていないユーザー）
- [x] インスタンスメソッドテスト
  - [x] administrator? メソッド
  - [x] director? メソッド
  - [x] soft_delete メソッド
  - [x] revive メソッド
  - [x] fill_absent メソッド
- [x] クラスメソッドテスト
  - [x] find_in_project メソッド

### Report モデル
- [x] バリデーションテスト
  - [x] worked_in の presence
- [x] アソシエーションテスト
  - [x] belongs_to :user
  - [x] has_many :operations, autosave: true
  - [x] has_many :projects, through: :operations
- [x] クラスメソッドテスト
  - [x] find_in_month メソッド
  - [x] find_in_week メソッド
  - [x] submitted_users メソッド
  - [x] unsubmitted_dates メソッド
  - [x] output_calendar メソッド

### Operation モデル
- [x] バリデーションテスト
  - [x] workload の数値検証（0より大きく100以下）
- [x] アソシエーションテスト
  - [x] belongs_to :report
  - [x] belongs_to :project
- [x] クラスメソッドテスト
  - [x] summary メソッド（期間集計）

### Project モデル
- [x] バリデーションテスト
  - [x] code の uniqueness と数値検証
  - [x] name の presence
  - [x] name_reading の presence とひらがなフォーマット
- [x] Enumテスト
  - [x] category の各値（undefined, client_shot, client_maintenance, internal, general_affairs, other）
- [x] アソシエーションテスト
  - [x] has_many :operations
  - [x] has_many :user_projects
  - [x] has_many :users, through: :user_projects
  - [x] has_many :estimates
  - [x] has_many :bills, through: :estimates
- [x] スコープテスト
  - [x] available スコープ（hidden: false）
  - [x] order_by_reading スコープ
- [x] クラスメソッドテスト
  - [x] find_in_user メソッド
  - [x] next_expected_code メソッド
- [x] インスタンスメソッドテスト
  - [x] members メソッド
  - [x] displayed? メソッド
  - [x] display_status メソッド

### Estimate モデル
- [x] バリデーションテスト
  - [x] serial_no の uniqueness
  - [x] subject の presence
  - [x] amount の数値検証
  - [x] filename の presence
  - [x] 工数の合計検証（EstimateValidator）
- [x] アソシエーションテスト
  - [x] belongs_to :project
  - [x] has_one :bill
- [x] インスタンスメソッドテスト
  - [x] deja_vu? メソッド
  - [x] too_old? メソッド

### Bill モデル
- [x] バリデーションテスト
  - [x] serial_no の uniqueness
  - [x] subject の presence
  - [x] amount の数値検証
  - [x] filename の presence
- [x] アソシエーションテスト
  - [x] belongs_to :estimate
- [x] インスタンスメソッドテスト
  - [x] tax_included_amount メソッド

### UserProject モデル
- [x] アソシエーションテスト
  - [x] belongs_to :user
  - [x] belongs_to :project
- [x] ユニーク制約のテスト
  - [x] user_id と project_id の組み合わせの一意性

### UserRole モデル
- [x] アソシエーションテスト
  - [x] has_many :user_role_associations
  - [x] has_many :users, through: :user_role_associations
- [x] バリデーションテスト
  - [x] role の presence
- [x] Enumテスト
  - [x] role の各値（administrator, director）
- [x] メソッドテスト
  - [x] administrator? メソッド
  - [x] director? メソッド

### UserRoleAssociation モデル
- [x] アソシエーションテスト
  - [x] belongs_to :user
  - [x] belongs_to :user_role
- [x] ユニーク制約のテスト
  - [x] user_id と user_role_id の組み合わせの一意性

## コントローラーテスト

### ApplicationController
- [x] 認証前のリダイレクト
- [x] ログイン後のリダイレクト
- [x] set_locale の動作
- [x] エラーハンドリング（Pundit、RecordNotFound、MissingTemplate、StandardError）
- [x] CSRF保護

### ReportsController
- [x] index アクション
  - [x] ログイン時の正常表示
  - [x] 未ログイン時のリダイレクト
  - [x] JSONレスポンスの検証
  - [x] CSVレスポンスの検証
- [x] show アクション
  - [x] 正常な日報の取得
  - [x] 権限のない日報へのアクセス制限
- [x] new アクション
- [x] create アクション
  - [x] 正常な日報の作成
  - [x] バリデーションエラー時の処理
  - [x] 作業時間の合計が100%になることの検証
- [x] edit アクション
- [x] update アクション
  - [x] 正常な更新
  - [x] バリデーションエラー時の処理
- [x] destroy アクション

### Reports::SummariesController
- [x] show アクション
  - [x] 集計データの正確性
  - [x] 期間指定の検証

### Reports::UnsubmittedsController
- [x] show アクション
  - [x] 未提出日の正確な取得
  - [x] 権限による表示制限

### ProjectsController
- [x] index アクション
  - [x] プロジェクト一覧の表示
  - [x] available スコープの適用確認
  - [x] ソート機能の検証
  - [x] CSVエクスポート機能
- [x] show アクション
  - [x] プロジェクト詳細の表示
  - [x] 見積もりと請求書の表示
- [x] new アクション（管理者権限）
  - [x] 新規プロジェクトフォームの表示
  - [x] プロジェクトコードの自動設定
- [x] create アクション
  - [x] 正常なプロジェクト作成
  - [x] プロジェクトコードの自動採番
  - [x] バリデーションエラー時の処理
- [x] edit アクション（管理者権限）
  - [x] プロジェクト編集フォームの表示
- [x] update アクション
  - [x] 正常な更新
  - [x] 権限チェック
  - [x] バリデーションエラー時の処理
- [x] destroy アクション（論理削除）
  - [x] 使用されていないプロジェクトの削除
  - [x] 使用中プロジェクトの削除制限

### Projects::MembersController
- [x] index アクション
  - [x] メンバー一覧の取得
- [x] update アクション
  - [x] メンバーの追加・削除
- [x] destroy アクション

### UsersController
- [x] index アクション（管理者権限）
- [x] show アクション
- [x] new アクション（管理者権限）
- [x] create アクション
  - [x] 正常なユーザー作成
  - [x] 権限の設定
- [x] edit アクション
- [x] update アクション
  - [x] 正常な更新
  - [x] 自分以外のユーザー編集の権限チェック
- [x] destroy アクション（論理削除）
- [x] revive アクション

### EstimatesController
- [x] index アクション
  - [x] 見積もり一覧の表示
- [x] create アクション
  - [x] 正常な見積もり作成
  - [x] PDFファイルのアップロード処理
- [x] confirm アクション

### BillsController
- [x] index アクション
  - [x] 請求書一覧の表示
- [x] create アクション
  - [x] 正常な請求書作成
  - [x] 見積もりとの関連付け
- [x] confirm アクション

### Settings::ProjectsController
- [x] index アクション
  - [x] ユーザーのプロジェクト設定表示
- [x] update アクション
  - [x] プロジェクトの表示/非表示切り替え

### Settings::PasswordsController
- [x] show アクション
- [x] update アクション
  - [x] パスワード変更の成功
  - [x] 現在のパスワードの検証
  - [x] 新しいパスワードの確認

### Admin::CsvsController
- [x] index アクション
  - [x] CSVインポート機能

## リクエストスペック（統合テスト）

### 認証フロー
- [x] ログイン → 日報作成 → ログアウトの一連の流れ
- [x] セッションタイムアウトの処理
- [x] Remember me機能の動作確認

### 日報作成フロー
- [x] 日報の新規作成から保存まで
- [x] 複数プロジェクトへの時間配分
- [x] 作業時間の合計が100%でない場合のエラー処理

### 権限管理
- [x] 一般ユーザーの操作制限
- [x] ディレクター権限の確認
- [x] 管理者権限の確認

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
- [x] ApplicationHelper のメソッド
- [ ] 各種フォーマット用ヘルパー

### Rake タスク
- [x] CSVインポートタスク（app:import_csv）

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
1. ✅ モデルのバリデーションとアソシエーション
2. ✅ 認証・認可機能
3. ✅ 基本的なCRUD操作
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