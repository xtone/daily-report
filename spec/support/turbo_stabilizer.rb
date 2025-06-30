# Turbo Drive関連のE2Eテスト安定化
module TurboStabilizer
  # Turbo Driveのフレーム更新を待つ
  def wait_for_turbo_frame(frame_id, timeout: Capybara.default_max_wait_time)
    wait_for_selector("turbo-frame##{frame_id}[complete]", timeout: timeout)
  end

  # Turbo Driveのストリーム更新を待つ
  def wait_for_turbo_stream(timeout: Capybara.default_max_wait_time)
    wait_for_javascript("!document.documentElement.hasAttribute('data-turbo-preview')", timeout: timeout)
  end

  # JavaScriptの評価を待つ
  def wait_for_javascript(condition, timeout: Capybara.default_max_wait_time)
    Timeout.timeout(timeout) do
      loop do
        result = page.evaluate_script(condition)
        break if result
        sleep 0.1
      end
    end
  rescue Timeout::Error
    raise "JavaScript condition '#{condition}' was not met within #{timeout} seconds"
  end

  # セレクタが表示されるまで待つ
  def wait_for_selector(selector, timeout: Capybara.default_max_wait_time)
    page.has_selector?(selector, wait: timeout)
  end

  # Turbo Driveのナビゲーションが完了するまで待つ
  def wait_for_turbo_navigation
    # Turbo Driveのイベントが完了するまで待つ
    wait_for_javascript("document.readyState === 'complete'")
    
    # 追加の待機（CI環境では必要な場合がある）
    if ENV['CI']
      sleep 0.5
    end
  end
end

RSpec.configure do |config|
  config.include TurboStabilizer, type: :feature
end