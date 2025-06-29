# 日報システム サイトマップ

## 認証不要なページ
- `/users/sign_in` - ログイン画面

## 認証が必要なページ

### メインページ
- `/` - ルート（日報一覧）
- `/reports` - 日報一覧

### 日報関連
- `/reports/new` - 新規日報作成
- `/reports/:id` - 日報詳細
- `/reports/:id/edit` - 日報編集
- `/reports/summary` - 日報サマリー
- `/reports/unsubmitted` - 未提出日報一覧

### プロジェクト関連
- `/projects` - プロジェクト一覧
- `/projects/new` - 新規プロジェクト作成
- `/projects/:id` - プロジェクト詳細
- `/projects/:id/edit` - プロジェクト編集
- `/projects/:id/members` - プロジェクトメンバー管理
- `/projects/members/edit` - メンバー編集

### 見積書・請求書関連
- `/estimates` - 見積書一覧
- `/estimates/confirm` - 見積書確認
- `/bills` - 請求書一覧
- `/bills/confirm` - 請求書確認

### ユーザー管理
- `/users` - ユーザー一覧
- `/users/new` - 新規ユーザー作成
- `/users/:id` - ユーザー詳細
- `/users/:id/edit` - ユーザー編集
- `/users/:id/revive` - ユーザー復活

### 設定関連
- `/settings/projects` - プロジェクト設定
- `/settings/password` - パスワード変更

### 管理者専用
- `/admin` - 管理者ダッシュボード
- `/admin/csvs` - CSV管理

## 注意事項
- 認証が必要なページは、テストユーザーまたはseedデータでログインが必要
- 管理者専用ページは管理者権限を持つユーザーでのアクセスが必要