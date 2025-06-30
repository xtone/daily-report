# Rails 8.0とturbo-rails 2.0.12の互換性パッチ
Rails.application.config.to_prepare do
  if defined?(Turbo::Engine)
    # Rails 8互換性のためのパッチ（テスト環境以外）
    unless Rails.env.test?
      Rails.application.config.turbo = ActiveSupport::OrderedOptions.new unless Rails.application.config.respond_to?(:turbo)
      Rails.application.config.turbo.draw_routes = true unless Rails.application.config.turbo.respond_to?(:draw_routes)
    end
  end
end

# テスト環境でTurbo Driveを確実に無効化
if Rails.env.test? && defined?(Turbo)
  Rails.configuration.after_initialize do
    Turbo.session.drive = false if defined?(Turbo.session)
  end
end