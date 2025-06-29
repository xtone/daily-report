# Turbo Drive configuration
if Rails.env.test?
  # Disable Turbo Drive in test environment to avoid E2E test issues
  Rails.application.config.turbo = false
end