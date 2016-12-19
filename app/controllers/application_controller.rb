class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  before_action :set_locale

  rescue_from StandardError, with: :render_500
  rescue_from Pundit::NotAuthorizedError, with: :render_403
  rescue_from ActionView::MissingTemplate, with: :render_404
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def render_403(error = nil)
    raise error unless Rails.env.production?
  end

  def render_404(error = nil)
    raise error unless Rails.env.production?
  end

  def render_500(error = nil)
    raise error unless Rails.env.production?
  end
end
