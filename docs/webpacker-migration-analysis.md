# Webpackerからjsbundling-railsへの移行分析

## 現状分析

### JavaScript/React構成
- **React**: 15.5.4（2017年リリース、古いバージョン）
- **Webpack**: 3.8.1（独自設定）
- **元Webpacker**: 3.0（現在は独自のwebpack.config.jsを使用）

### エントリーポイント（9個）
1. `application.js` - 基本設定とTurbolinks
2. `admin.jsx` - 管理画面
3. `bills.jsx` - 請求書管理
4. `estimates.jsx` - 見積もり管理
5. `forms.jsx` - フォーム関連
6. `project_list.jsx` - プロジェクト一覧
7. `project_members.jsx` - プロジェクトメンバー管理
8. `reports.jsx` - 日報管理（メイン機能）
9. `reports_summary.jsx` - 日報集計
10. `unsubmitted.jsx` - 未提出日報

### アセット処理の現状
- **JavaScript**: Webpack（独自設定）でバンドル
- **CSS**: Rails Asset Pipeline（Sprockets）で処理
- **画像**: Rails Asset Pipeline（Sprockets）で処理

### 使用している主要なライブラリ
- React 15.5.4
- Turbolinks 5.0.3
- Bootstrap 3 Datetimepicker
- jQuery（honoka-rails経由）

## 移行の影響度評価

### 低リスク項目
1. **CSS処理**: すでにAsset Pipelineで処理されているため影響なし
2. **画像処理**: すでにAsset Pipelineで処理されているため影響なし
3. **JSX/TypeScript**: 使用していないため、複雑な設定は不要

### 中リスク項目
1. **複数エントリーポイント**: jsbundling-railsでも対応可能だが設定が必要
2. **カスタムマニフェスト生成**: scripts/generate-manifest.jsの移行が必要
3. **ハッシュ付きファイル名**: jsbundling-railsでの実装方法確認が必要

### 高リスク項目
1. **React 15.5.4**: 非常に古いバージョンのため、将来的な更新を検討
2. **Turbolinks統合**: Turbo（Turbolinks後継）への移行も視野に

## 移行戦略

### フェーズ1: jsbundling-railsへの移行（優先度：高）
1. jsbundling-rails gemの追加
2. webpack.config.jsの調整（エントリーポイント、出力設定）
3. package.jsonのスクリプト更新
4. マニフェスト生成の移行
5. ビューファイルの更新（javascript_pack_tag → javascript_include_tag）

### フェーズ2: 依存関係の更新（優先度：中）
1. Webpack 5への更新
2. Babel 7への更新
3. その他の依存関係の更新

### フェーズ3: React更新（優先度：低、別Issue）
1. React 16への段階的更新
2. React 17への更新
3. React 18への更新

## テスト計画

### 単体テスト
- 各Reactコンポーネントの動作確認
- API通信の動作確認

### 統合テスト
- 日報登録・編集・削除の一連の流れ
- プロジェクト管理機能
- 請求書・見積もり管理機能

### パフォーマンステスト
- ビルド時間の比較
- バンドルサイズの比較
- ページロード時間の比較

## リスク軽減策

1. **段階的移行**: まず開発環境で完全に動作確認してから本番環境へ
2. **ロールバック計画**: 移行前の状態に戻せるよう、ブランチとタグを適切に管理
3. **並行稼働**: 一時的に両方の設定を残し、問題があれば切り戻し可能に
4. **十分なテスト**: 自動テストと手動テストの両方を実施

## 次のステップ

1. このドキュメントをレビューし、チームで移行計画を承認
2. jsbundling-railsへの移行実装（Issue #153）
3. 移行完了後、Webpackerの削除（Issue #154）