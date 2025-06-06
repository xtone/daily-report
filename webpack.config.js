const path = require('path');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const webpack = require('webpack');
const { execSync } = require('child_process');

const isProduction = process.env.NODE_ENV === 'production';

// カスタムプラグイン：ビルド後にマニフェストを生成
class GenerateManifestPlugin {
  apply(compiler) {
    compiler.plugin('done', () => {
      try {
        execSync('node scripts/generate-manifest.js', { stdio: 'inherit' });
      } catch (error) {
        console.error('Failed to generate manifest:', error);
      }
    });
  }
}

module.exports = {
  entry: {
    admin: './app/javascript/packs/admin.jsx',
    bills: './app/javascript/packs/bills.jsx',
    estimates: './app/javascript/packs/estimates.jsx',
    forms: './app/javascript/packs/forms.jsx',
    project_list: './app/javascript/packs/project_list.jsx',
    project_members: './app/javascript/packs/project_members.jsx',
    reports: './app/javascript/packs/reports.jsx',
    reports_summary: './app/javascript/packs/reports_summary.jsx',
    unsubmitted: './app/javascript/packs/unsubmitted.jsx'
  },

  output: {
    path: path.resolve(__dirname, 'public/packs'),
    filename: '[name]-[hash].js',
    publicPath: '/packs/'
  },

  resolve: {
    extensions: ['.js', '.jsx', '.sass', '.scss', '.css', '.png', '.svg', '.gif', '.jpeg', '.jpg']
  },

  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['env', 'react'],
            plugins: ['transform-class-properties', 'syntax-dynamic-import']
          }
        }
      },
      {
        test: /\.s[ac]ss$/i,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: [
            'css-loader',
            {
              loader: 'sass-loader',
              options: {
                implementation: require('sass')
              }
            }
          ]
        })
      },
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: 'css-loader'
        })
      },
      {
        test: /\.(png|jpe?g|gif|svg|eot|ttf|woff|woff2)$/i,
        use: {
          loader: 'file-loader',
          options: {
            name: '[name]-[hash].[ext]',
            outputPath: 'assets/'
          }
        }
      }
    ]
  },

  plugins: [
    new ExtractTextPlugin({
      filename: '[name]-[hash].css',
      disable: !isProduction
    }),
    new GenerateManifestPlugin(),
    // webpack 3.x用の本番環境設定
    ...(isProduction ? [
      new webpack.DefinePlugin({
        'process.env.NODE_ENV': JSON.stringify('production')
      }),
      new webpack.optimize.UglifyJsPlugin({
        compress: {
          warnings: false
        }
      })
    ] : [])
  ],

  devtool: isProduction ? false : 'eval-cheap-module-source-map'
}; 