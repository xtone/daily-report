module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    # jQueryがある場合はajaxリクエストが完了するまで待つ
    if page.evaluate_script('typeof jQuery !== "undefined"')
      page.evaluate_script('jQuery.active').zero?
    else
      true
    end
  end
  
  # ページが完全に読み込まれるまで待つ
  def wait_for_document_ready
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until page.evaluate_script('document.readyState') == 'complete'
    end
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end