#!/bin/bash

# React 18への移行スクリプト
# ReactDOM.renderをcreateRootに更新

echo "Updating React components to use React 18 createRoot API..."

# 対象ファイルのリスト
files=(
  "app/javascript/packs/bills.jsx"
  "app/javascript/packs/estimates.jsx"
  "app/javascript/packs/forms.jsx"
  "app/javascript/packs/project_list.jsx"
  "app/javascript/packs/project_members.jsx"
  "app/javascript/packs/reports.jsx"
  "app/javascript/packs/reports_summary.jsx"
  "app/javascript/packs/unsubmitted.jsx"
)

for file in "${files[@]}"; do
  echo "Processing $file..."
  
  # インポートを追加（既に存在していない場合）
  if ! grep -q "import { createRoot }" "$file"; then
    sed -i "s/import ReactDOM from 'react-dom'/import ReactDOM from 'react-dom'\nimport { createRoot } from 'react-dom\/client'/" "$file"
  fi
  
  # ReactDOM.render()をcreateRoot().render()に変換
  # document.addEventListener内のパターンを検索して変換
  perl -i -pe '
    if (/document\.addEventListener.*turbo(?:links)?:load.*\{/) {
      $in_listener = 1;
    }
    if ($in_listener && /ReactDOM\.render\((.+?),\s*(.+?)\);/) {
      my $component = $1;
      my $container = $2;
      $_ = "  const root = createRoot($container);\n  root.render($component);\n";
      $in_listener = 0;
    }
  ' "$file"
  
  # unmountComponentAtNodeを削除またはコメントアウト
  sed -i 's/ReactDOM\.unmountComponentAtNode/\/\/ React 18では不要: ReactDOM.unmountComponentAtNode/g' "$file"
  
  echo "✓ Updated $file"
done

echo "All files have been updated for React 18!"