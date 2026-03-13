module SystemAdmin
  class FeatureFlagsController < SystemAdmin::BaseController
    before_action :set_feature, only: %i[show destroy toggle enable_actor disable_actor]

    def index
      @features = Flipper.features.sort_by(&:key)
    end

    def show
      @actors = Flipper::Adapters::ActiveRecord::Gate
                .where(feature_key: @feature.key, key: 'actors')
                .pluck(:value)
      actor_ids = @actors.filter_map { |v| v.delete_prefix('User;') }
      @actor_users = User.where(id: actor_ids).index_by { |u| u.id.to_s }
    end

    def new; end

    def create
      key = params[:feature_key].to_s.strip

      unless key.match?(/\A[a-z][a-z0-9_]*\z/)
        flash[:alert] = t('system_admin.feature_flags.invalid_key')
        render :new, status: :unprocessable_entity
        return
      end

      if Flipper.features.any? { |f| f.key == key }
        flash[:alert] = t('system_admin.feature_flags.already_exists')
        render :new, status: :unprocessable_entity
        return
      end

      Flipper.add(key)
      redirect_to system_admin_feature_flag_path(key), notice: t('system_admin.feature_flags.created')
    end

    def destroy
      Flipper.remove(@feature.key)
      redirect_to system_admin_feature_flags_path, notice: t('system_admin.feature_flags.deleted')
    end

    def toggle
      if @feature.enabled?
        @feature.disable
      else
        @feature.enable
      end
      redirect_to system_admin_feature_flag_path(@feature.key),
                  notice: t('system_admin.feature_flags.toggled')
    end

    def enable_actor
      user = User.find(params[:user_id])
      @feature.enable_actor(user)
      redirect_to system_admin_feature_flag_path(@feature.key),
                  notice: t('system_admin.feature_flags.actor_enabled', user: user.name)
    end

    def disable_actor
      user = User.find(params[:user_id])
      @feature.disable_actor(user)
      redirect_to system_admin_feature_flag_path(@feature.key),
                  notice: t('system_admin.feature_flags.actor_disabled', user: user.name)
    end

    private

    def set_feature
      @feature = Flipper.feature(params[:id])
      return if Flipper.features.any? { |f| f.key == @feature.key }

      redirect_to system_admin_feature_flags_path, alert: t('system_admin.feature_flags.not_found')
    end
  end
end
