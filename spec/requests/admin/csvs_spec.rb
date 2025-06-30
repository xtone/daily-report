require 'rails_helper'

RSpec.describe 'Admin::Csvs', type: :request do
  let(:admin_user) { create(:user, :administrator) }
  let(:normal_user) { create(:user) }

  describe 'GET /admin/csvs' do
    context '管理者権限でログインしている場合' do
      before do
        post user_session_path, params: {
          user: {
            email: admin_user.email,
            password: 'password'
          }
        }
      end

      it 'CSVインポート画面が表示される' do
        get admin_csvs_path
        expect(response).to have_http_status(:success)
      end
    end

    context '一般ユーザーでログインしている場合' do
      before do
        post user_session_path, params: {
          user: {
            email: normal_user.email,
            password: 'password'
          }
        }
      end

      it 'アクセスできる（認証のみ必要）' do
        get admin_csvs_path
        expect(response).to have_http_status(:success)
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされる' do
        get admin_csvs_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
