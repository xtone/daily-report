# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# Precompile JavaScript bundles
Rails.application.config.assets.precompile += %w[
  admin.js
  bills.js
  estimates.js
  forms.js
  project_list.js
  project_members.js
  reports.js
  reports_summary.js
  unsubmitted.js
]

# CoffeeScriptプロセッサーを無効化（React移行完了のため）
# 注意: 現在のSprocketsバージョンでは無効化メソッドが利用できないため、
# coffee-railsを一時的に残してアセットパイプラインとの互換性を保つ
# Rails.application.config.assets.configure do |env|
#   # CoffeeScriptプロセッサーが存在する場合のみ無効化
#   if defined?(Sprockets::CoffeeScriptProcessor)
#     begin
#       env.unregister_processor('application/javascript', Sprockets::CoffeeScriptProcessor)
#     rescue NoMethodError
#       # unregister_processorメソッドが存在しない場合は何もしない
#     end
#   end
#   
#   # CoffeeScriptトランスフォーマーを無効化（安全な方法）
#   if env.respond_to?(:transformers) && env.transformers.respond_to?(:[])
#     begin
#       env.transformers.delete('text/coffeescript') if env.transformers['text/coffeescript']
#     rescue
#       # エラーが発生した場合は何もしない
#     end
#   end
# end
