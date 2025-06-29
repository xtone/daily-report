module TurboHelpers
  # Turbo Driveのページ遷移が完了するまで待機
  def wait_for_turbo_drive
    # Turbo Driveの遷移が完了したことを確認
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        # turbo:loadイベントが発火し、ページが安定したことを確認
        break if page.evaluate_script('document.documentElement.hasAttribute("data-turbo-preview")')
        break if page.evaluate_script('!!window.Turbo && !window.Turbo.navigator.currentVisit')
        sleep 0.1
      end
    end
    
    # CI環境では追加の待機
    sleep 0.5 if ENV['CI']
  rescue Timeout::Error
    # タイムアウトした場合でも続行
  end

  # ページ読み込み完了を待つ
  def wait_for_page_load
    wait_for_turbo_drive
    
    # DOMが安定するまで待機
    page.has_css?('body', wait: 2)
    
    # CI環境では追加の待機
    if ENV['CI']
      sleep 0.3
      # ネットワーク活動が完了するまで待機
      page.evaluate_script('jQuery.active == 0') if page.evaluate_script('typeof jQuery !== "undefined"')
    end
  end

  # 要素が表示されてクリック可能になるまで待つ
  def wait_and_click(selector, text = nil)
    wait_for_page_load
    
    element = if text
                find(selector, text: text, visible: true, wait: 5)
              else
                find(selector, visible: true, wait: 5)
              end
    
    # 要素が見えるまでスクロール
    element.scroll_to(element, align: :center) if element.respond_to?(:scroll_to)
    
    # クリック可能になるまで待機
    sleep 0.2 if ENV['CI']
    element.click
    
    wait_for_turbo_drive
  end
end

RSpec.configure do |config|
  config.include TurboHelpers, type: :feature
end