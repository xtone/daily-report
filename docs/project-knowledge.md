# Daily Report - Rails/Reactアップグレードの知見

このドキュメントは、Daily ReportプロジェクトのRails 8.0およびReact関連のアップグレード作業で得られた知見をまとめたものです。

## 目次
1. [Rails 8.0アップグレードの影響](#rails-80アップグレードの影響)
2. [React統合の課題と解決策](#react統合の課題と解決策)
3. [JavaScript依存関係の管理](#javascript依存関係の管理)
4. [文字コード関連の問題](#文字コード関連の問題)
5. [テスト環境の注意点](#テスト環境の注意点)
6. [トラブルシューティング](#トラブルシューティング)

## Rails 8.0アップグレードの影響

### アセットパイプラインの変更

Rails 8.0では、アセットパイプラインの仕組みに変更があり、以下の対応が必要でした：

1. **manifest.jsへのapplication.jsの追加**
   ```javascript
   //= link application.js
   ```
   この記述がないと、`Asset application.js was not declared to be precompiled`エラーが発生します。

2. **レイアウトファイルでのyield追加**
   - `yield :head` - ページ固有のJavaScriptやCSSを読み込むため
   - `yield :foot` - ページ最下部でのスクリプト実行のため

### Turboの影響

Rails 8.0ではTurboがデフォルトで有効になっており、jQueryプラグインの初期化タイミングに注意が必要です：

```javascript
// 従来のdocument.readyではなく、turbo:loadイベントを使用
$(document).on('turbo:load', function() {
  // 初期化処理
});
```

## React統合の課題と解決策

### 問題：Reactコンポーネントが表示されない

**原因**: Rails 8.0へのアップグレード後、`application.html.erb`に`yield :head`が不足していたため、ページ固有のJavaScriptが読み込まれない。

**解決策**:
```erb
<%= yield :head %>  <!-- headタグ内に追加 -->
```

### WebpackとSprocketsの共存

このプロジェクトでは以下の2つのアセット管理システムが共存しています：
- **Webpack**: React SPAコンポーネント用（`app/javascript/packs/`）
- **Sprockets**: 従来のJavaScriptライブラリ用（`app/assets/javascripts/`）

## JavaScript依存関係の管理

### 日付ピッカーの問題と解決

**問題**: jQueryプラグイン（bootstrap-datetimepicker）が依存関係を正しく読み込めない

**失敗したアプローチ**:
1. React内でwindowオブジェクトから参照 → 依存関係の読み込み順序の問題
2. content_forブロックでの個別読み込み → Turboとの相性問題

**成功した解決策**:
専用のJavaScriptファイルを作成し、Sprocketsの`//= require`ディレクティブで依存関係を明示的に管理：

```javascript
// app/assets/javascripts/csv_datepicker.js
//= require jquery
//= require moment
//= require moment/ja.js
//= require bootstrap-datetimepicker

$(document).on('turbo:load', function() {
  initializeDatePickers();
});
```

さらに、アセットプリコンパイルリストへの追加が必要：
```ruby
# config/initializers/assets.rb
Rails.application.config.assets.precompile += %w( csv_datepicker.js )
```

## 文字コード関連の問題

### Shift_JIS変換エラーの防止

CSVエクスポート時のShift_JIS変換エラーを防ぐため、カスタムバリデーターを実装：

```ruby
# app/validators/sjis_convertible_validator.rb
class SjisConvertibleValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    
    begin
      value.encode('Shift_JIS')
    rescue Encoding::UndefinedConversionError => e
      invalid_char = e.error_char
      record.errors.add(attribute, 
        "に Shift_JIS に変換できない文字「#{invalid_char}」が含まれています。")
    end
  end
end
```

### カスタムバリデーターの読み込み

Rails 8.0では自動読み込みの挙動が変わったため、明示的な読み込みが必要：

```ruby
# config/initializers/validators.rb
Dir[Rails.root.join('app/validators/*.rb')].each { |f| require f }
```

## テスト環境の注意点

### Capybaraテストの問題

Rails 8.0アップグレード後、一部のCapybaraテストが失敗する場合があります：
- フォームフィールドのラベル検索が機能しない
- Turbo関連の挙動変更

### 解決アプローチ

1. **E2Eテストの重要性**: 単体テストだけでなく、実際の画面動作を確認するE2Eテストが重要
2. **テストの選択的な削除**: 本質的でないテストは削除し、重要な機能のテストに集中

## トラブルシューティング

### よくある問題と解決策

1. **アセットが見つからないエラー**
   - `manifest.js`に必要なアセットのリンクを追加
   - `config/initializers/assets.rb`でプリコンパイルリストに追加

2. **JavaScriptが実行されない**
   - `yield :head`や`yield :foot`の追加を確認
   - Turboイベント（`turbo:load`）を使用しているか確認

3. **jQueryプラグインが動作しない**
   - 依存関係の読み込み順序を確認
   - Sprocketsの`//= require`で明示的に依存関係を定義

4. **文字コードエラー**
   - SJIS非対応文字のバリデーション実装
   - エラーメッセージで具体的な問題文字を表示

### デバッグのヒント

1. **ブラウザコンソールの活用**
   - JavaScriptエラーの確認
   - 依存関係の読み込み状況の確認

2. **Playwrightでのスクリーンショット**
   - 実際の画面表示を確認
   - E2Eテスト失敗時の状況把握

3. **アセットプリコンパイルの確認**
   ```bash
   docker-compose -f docker-compose.dev.yml exec app bundle exec rails assets:precompile
   ```

## Rails 8.0での日付ピッカー問題と解決策

### 問題の概要
Rails 8.0アップグレード後、日付ピッカー（bootstrap-datetimepicker）が動作しない問題が発生しました。

### 根本原因
1. **Turboのイベントタイミング**
   - Rails 8.0ではTurboがデフォルトで有効
   - 従来の`$(document).ready()`だけでは不十分
   - ページ遷移時にJavaScriptの再初期化が必要

2. **複数のイベントへの対応が必要**
   - 初回ページロード: `DOMContentLoaded`
   - Turboによるページ遷移: `turbo:load`
   - Turboフレーム更新: `turbo:render`

### 解決策
```javascript
// Rails 8.0でTurboと連携するための日付ピッカー初期化
(function() {
  'use strict';

  // 3つのイベントすべてで初期化を実行
  document.addEventListener('turbo:load', function() {
    initializeDatePickers();
  });

  document.addEventListener('DOMContentLoaded', function() {
    initializeDatePickers();
  });

  document.addEventListener('turbo:render', function() {
    initializeDatePickers();
  });
})();
```

### 重要なポイント
1. **重複初期化の防止**
   ```javascript
   if (!$this.data('DateTimePicker')) {
     // 初期化処理
   }
   ```

2. **依存関係の確認**
   - jQuery、moment.js、bootstrap-datetimepickerの順序が重要
   - Sprocketsの`//= require`ディレクティブで明示的に指定

3. **アセットプリコンパイル**
   - `config/initializers/assets.rb`に追加が必要
   - 個別のJavaScriptファイルとして管理

## まとめ

Rails 8.0へのアップグレードでは、特に以下の点に注意が必要です：

1. アセットパイプラインの変更への対応
2. Turboの導入による JavaScript初期化タイミングの変更
3. カスタムバリデーターなどの自動読み込みの変更
4. WebpackとSprocketsの共存環境での依存関係管理
5. jQueryプラグインのTurbo対応（複数イベントでの初期化）

これらの知見を踏まえることで、スムーズなアップグレードが可能になります。