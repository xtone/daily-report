# Rails 8.0とturbo-rails 2.0.12の互換性パッチ
Rails.application.config.to_prepare do
  if defined?(Turbo::Engine)
    # Rails 8互換性のためのパッチ
    Rails.application.config.turbo = ActiveSupport::OrderedOptions.new unless Rails.application.config.respond_to?(:turbo)
    Rails.application.config.turbo.draw_routes = true unless Rails.application.config.turbo.respond_to?(:draw_routes)
  end
end