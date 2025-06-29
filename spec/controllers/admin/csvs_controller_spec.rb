require 'rails_helper'

RSpec.describe Admin::CsvsController, type: :controller do
  let(:admin_user) { create(:user, :administrator) }
  let(:normal_user) { create(:user) }

  describe 'GET #index' do
    context '管理者権限でログインしている場合' do
      before { sign_in admin_user }

      it 'CSVインポート画面が表示される' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context '一般ユーザーでログインしている場合' do
      before { sign_in normal_user }

      it 'アクセスできる（認証のみ必要）' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされる' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
