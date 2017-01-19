Rails.application.config.i18n.available_locales = %i(ja en)
Rails.application.config.i18n.default_locale = :ja
Rails.application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]