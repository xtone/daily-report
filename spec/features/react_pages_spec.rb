require 'rails_helper'

RSpec.feature 'React Pages', :js, type: :feature do
  let(:user) { create(:user) }
  let(:project) { create(:project, name: 'テストプロジェクト') }

  before do
    user.save!
    user.update_column(:encrypted_password, Digest::MD5.hexdigest('password' + user.id.to_s))

    create(:user_project, user: user, project: project)
    sign_in_as(user)
  end

  describe '日報入力画面' do
    scenario '日報入力フォームが表示される' do
      visit '/'

      # Reactコンポーネントが読み込まれるまで待機
      expect(page).to have_css('.container', wait: 10)

      # 日付選択が可能か確認
      today = Date.today
      expect(page).to have_content(today.year)
      expect(page).to have_content("#{today.month}月")
    end
  end

  describe 'JavaScriptエラーの確認' do
    scenario '各ページでJavaScriptエラーが発生しない' do
      pages_to_check = [
        '/',
        '/settings/projects',
        '/settings/password'
      ]

      pages_to_check.each do |path|
        visit path
        # ページが正常に読み込まれることを確認
        expect(page).not_to have_content('Exception')
        expect(page).not_to have_content('SyntaxError')
        expect(page).not_to have_content('ReferenceError')
        # JavaScriptが実行されていることを確認
        if path == '/'
          # 日報ページには月のカレンダーが表示される
          expect(page).to have_content("#{Date.today.month}月")
        elsif path == '/settings/projects'
          # プロジェクト設定ページの特定の要素を確認
          expect(page).to have_content('参加プロジェクト設定')
        end
      end
    end
  end
end
