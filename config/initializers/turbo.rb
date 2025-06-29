# テスト環境ではTurbo Driveを無効化
if Rails.env.test?
  Rails.application.config.turbo.drive = false
end