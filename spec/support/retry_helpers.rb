module RetryHelpers
  # CI環境でSeleniumエラーが発生した場合にリトライする
  def with_retry(max_attempts: 3, wait: 1)
    attempt = 0
    begin
      attempt += 1
      yield
    rescue Selenium::WebDriver::Error::UnknownError, 
           Selenium::WebDriver::Error::StaleElementReferenceError,
           Selenium::WebDriver::Error::ElementClickInterceptedError => e
      if ENV['CI'] && attempt < max_attempts
        # CI環境でのみリトライ
        puts "[Retry #{attempt}/#{max_attempts}] #{e.class}: #{e.message}"
        sleep wait
        retry
      else
        raise e
      end
    end
  end

  # ページ遷移を伴う操作をリトライ付きで実行
  def visit_with_retry(path, content_to_wait_for = nil)
    with_retry do
      visit path
      if content_to_wait_for
        expect(page).to have_content(content_to_wait_for, wait: 10)
      end
      wait_for_page_load if respond_to?(:wait_for_page_load)
    end
  end

  # クリック操作をリトライ付きで実行
  def click_link_with_retry(locator, options = {})
    with_retry do
      wait_for_page_load if respond_to?(:wait_for_page_load)
      click_link locator, options
      wait_for_page_load if respond_to?(:wait_for_page_load)
    end
  end

  # ボタンクリックをリトライ付きで実行
  def click_button_with_retry(locator, options = {})
    with_retry do
      wait_for_page_load if respond_to?(:wait_for_page_load)
      click_button locator, options
      wait_for_page_load if respond_to?(:wait_for_page_load)
    end
  end
end

RSpec.configure do |config|
  config.include RetryHelpers, type: :feature
  
  # CI環境ではテスト自体もリトライ
  if ENV['CI']
    config.around(:each, type: :feature) do |example|
      attempts = 0
      begin
        attempts += 1
        example.run
      rescue Selenium::WebDriver::Error::UnknownError => e
        if attempts < 2 && e.message.match?(/Node with given id|element.*intercepted|stale element/)
          puts "[Test Retry] Retrying due to: #{e.message}"
          # ブラウザをリセット
          Capybara.reset_sessions!
          Capybara.use_default_driver
          retry
        else
          raise
        end
      end
    end
  end
end