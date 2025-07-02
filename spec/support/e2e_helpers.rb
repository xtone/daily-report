require 'digest/md5'

module E2EHelpers
  include TurboHelpers if defined?(TurboHelpers)
  
  def sign_in_as(user)
    visit '/users/sign_in'
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'
    
    # ログイン後のページ遷移を安全に待つ
    retries = 0
    max_retries = 3
    
    begin
      # ログインが成功したことを確認（日報ページにリダイレクトされる）
      expect(page).to have_content('日報', wait: ENV['CI'] ? 15 : 10)
      # Turbo Driveのページ遷移が完了するのを待つ
      expect(page).to have_css('.navbar', wait: ENV['CI'] ? 15 : 10)
      wait_for_page_load if respond_to?(:wait_for_page_load)
    rescue Selenium::WebDriver::Error::UnknownError => e
      if e.message.include?('Node with given id does not belong to the document') && retries < max_retries
        retries += 1
        sleep 1
        retry
      else
        raise e
      end
    end
  end

  # Turbo Driveのナビゲーションを確実に待つためのヘルパー
  def visit_and_wait(path, content_to_wait_for)
    visit path
    expect(page).to have_content(content_to_wait_for, wait: 5)
  end

  def sign_in_as_admin
    admin = create(:user, :administrator, email: 'admin@example.com')
    # 保存後にIDが確定してから暗号化パスワードを更新
    admin.update_column(:encrypted_password, Digest::MD5.hexdigest("password#{admin.id}"))
    sign_in_as(admin)
  end

  def sign_in_as_user
    user = create(:user, email: 'user@example.com')
    # 保存後にIDが確定してから暗号化パスワードを更新
    user.update_column(:encrypted_password, Digest::MD5.hexdigest("password#{user.id}"))
    sign_in_as(user)
  end

  def expect_page_to_load_successfully
    expect(page).to have_http_status(:success)
    expect(page).not_to have_content('Exception')
    expect(page).not_to have_content('Error')
    expect(page).not_to have_content('We\'re sorry')
  end

  def take_screenshot_on_failure
    return unless RSpec.current_example.exception

    # スクリーンショットディレクトリを作成
    FileUtils.mkdir_p('tmp/screenshots')
    
    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    filename = "screenshot_#{timestamp}_#{RSpec.current_example.full_description.gsub(/[^0-9A-Za-z.\-]/, '_')}.png"
    page.save_screenshot("tmp/screenshots/#{filename}")
    puts "Screenshot saved: tmp/screenshots/#{filename}"
  end
end

RSpec.configure do |config|
  config.include E2EHelpers, type: :feature

  config.after(:each, type: :feature) do
    take_screenshot_on_failure
  end
end
