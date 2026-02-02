module SystemAdmin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    layout 'system_admin'

    private

    def authorize_admin!
      return if current_user&.administrator?

      redirect_to root_path, alert: I18n.t('system_admin.unauthorized')
    end
  end
end
