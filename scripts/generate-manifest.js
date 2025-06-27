const fs = require('fs');
const path = require('path');

// public/packsディレクトリ内のファイルを読み取り
const packsDir = path.join(__dirname, '..', 'public', 'packs');
const manifestPath = path.join(packsDir, 'manifest.json');

function generateManifest() {
  if (!fs.existsSync(packsDir)) {
    console.log('public/packs directory does not exist');
    return;
  }

  const files = fs.readdirSync(packsDir);
  let manifest = {};

  // 既存のマニフェストファイルがあれば読み込む（Railsアセットを保持するため）
  if (fs.existsSync(manifestPath)) {
    try {
      const existingManifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
      manifest = { ...existingManifest };
      console.log('Loaded existing manifest:', Object.keys(manifest));
    } catch (error) {
      console.log('Failed to load existing manifest, starting fresh');
    }
  }

  // まずハッシュ付きファイルを処理
  files.forEach(file => {
    if (file.endsWith('.js') || file.endsWith('.css')) {
      const match = file.match(/^(.+?)-[a-f0-9]+\.(js|css)$/);
      if (match) {
        const baseName = `${match[1]}.${match[2]}`;
        manifest[baseName] = `/packs/${file}`;
        console.log(`Mapped ${baseName} -> ${file}`);
      }
    }
  });

  // ハッシュなしファイルは、対応するハッシュ付きファイルがない場合のみ追加
  files.forEach(file => {
    if (file.endsWith('.js') || file.endsWith('.css')) {
      const match = file.match(/^(.+?)-[a-f0-9]+\.(js|css)$/);
      if (!match && !manifest[file]) {
        manifest[file] = `/packs/${file}`;
        console.log(`Added fallback ${file}`);
      }
    }
  });

  // manifest.jsonを生成
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
  console.log('Generated manifest.json:', manifest);
}

generateManifest(); 