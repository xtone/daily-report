const path = require('path');
const webpack = require('webpack');

const isProduction = process.env.NODE_ENV === 'production';

module.exports = {
  entry: {
    bills: './app/javascript/packs/bills.jsx',
    estimates: './app/javascript/packs/estimates.jsx',
    project_list: './app/javascript/packs/project_list.jsx',
    project_members: './app/javascript/packs/project_members.jsx',
    reports: './app/javascript/packs/reports.jsx'
  },

  output: {
    path: path.resolve(__dirname, 'app/assets/builds'),
    filename: '[name].js',
    publicPath: '/assets/'
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
            plugins: ['transform-class-properties']
          }
        }
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
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify(isProduction ? 'production' : 'development')
    })
  ],

  devtool: isProduction ? false : 'eval-cheap-module-source-map'
}; 