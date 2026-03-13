module FeatureFlaggable
  extend ActiveSupport::Concern

  included do
    helper_method :feature_enabled?
  end

  def feature_enabled?(feature_name, actor = nil)
    if actor
      Flipper.enabled?(feature_name, actor)
    else
      Flipper.enabled?(feature_name)
    end
  end
end
