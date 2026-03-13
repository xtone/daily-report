require 'rails_helper'

RSpec.describe SystemAdmin::FeatureFlagsController, type: :controller do
  let(:admin_user) { create(:user, :administrator) }
  let(:normal_user) { create(:user) }

  describe '認証・認可' do
    context 'without login' do
      it 'ログインページにリダイレクトされる' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with non-admin user' do
      before { sign_in normal_user }

      it 'トップページにリダイレクトされる' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '管理者権限でログインしている場合' do
    before { sign_in admin_user }

    describe 'GET #index' do
      it '一覧画面が表示される' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #new' do
      it '新規作成画面が表示される' do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #create' do
      it 'フラグを作成できる' do
        post :create, params: { feature_key: 'test_feature' }
        expect(response).to redirect_to(system_admin_feature_flag_path('test_feature'))
        expect(Flipper.features.map(&:key)).to include('test_feature')
      end

      it '不正なキーの場合はエラーになる' do
        post :create, params: { feature_key: '123invalid' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it '重複キーの場合はエラーになる' do
        Flipper.add('existing_feature')
        post :create, params: { feature_key: 'existing_feature' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe 'GET #show' do
      before { Flipper.add('show_feature') }

      it '詳細画面が表示される' do
        get :show, params: { id: 'show_feature' }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'DELETE #destroy' do
      before { Flipper.add('delete_feature') }

      it 'フラグを削除できる' do
        delete :destroy, params: { id: 'delete_feature' }
        expect(response).to redirect_to(system_admin_feature_flags_path)
        expect(Flipper.features.map(&:key)).not_to include('delete_feature')
      end
    end

    describe 'PATCH #toggle' do
      before { Flipper.add('toggle_feature') }

      it '無効なフラグを有効にできる' do
        patch :toggle, params: { id: 'toggle_feature' }
        expect(response).to redirect_to(system_admin_feature_flag_path('toggle_feature'))
        expect(Flipper.enabled?(:toggle_feature)).to be true
      end

      it '有効なフラグを無効にできる' do
        Flipper.enable(:toggle_feature)
        patch :toggle, params: { id: 'toggle_feature' }
        expect(response).to redirect_to(system_admin_feature_flag_path('toggle_feature'))
        expect(Flipper.enabled?(:toggle_feature)).to be false
      end
    end

    describe 'POST #enable_actor' do
      let(:target_user) { create(:user) }

      before { Flipper.add('actor_feature') }

      it 'ユーザー単位でフラグを有効にできる' do
        post :enable_actor, params: { id: 'actor_feature', user_id: target_user.id }
        expect(response).to redirect_to(system_admin_feature_flag_path('actor_feature'))
        expect(Flipper.enabled?(:actor_feature, target_user)).to be true
      end
    end

    describe 'DELETE #disable_actor' do
      let(:target_user) { create(:user) }

      before do
        Flipper.add('actor_feature')
        Flipper.enable_actor(:actor_feature, target_user)
      end

      it 'ユーザー単位でフラグを無効にできる' do
        delete :disable_actor, params: { id: 'actor_feature', user_id: target_user.id }
        expect(response).to redirect_to(system_admin_feature_flag_path('actor_feature'))
        expect(Flipper.enabled?(:actor_feature, target_user)).to be false
      end
    end
  end
end
