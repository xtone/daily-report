require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:admin_user) { create(:user, :administrator, email: 'admin@example.com') }
  let(:director_user) { create(:user, :director, email: 'director@example.com') }
  let(:normal_user) { create(:user, email: 'normal@example.com') }
  let(:target_user) { create(:user, email: 'target@example.com') }

  describe 'GET #index' do
    context '管理者権限でログインしている場合' do
      before { sign_in admin_user }

      it 'ユーザー一覧が表示される' do
        get :index
        expect(response).to have_http_status(:success)
        expect(assigns(:users)).to include(admin_user)
      end

      it 'active=trueの場合、利用可能なユーザーのみ表示される' do
        deleted_user = create(:user, deleted_at: Time.current, email: 'deleted@example.com')
        get :index, params: { active: 'true' }
        expect(assigns(:users)).to include(admin_user)
        expect(assigns(:users)).not_to include(deleted_user)
      end

      it 'CSVフォーマットでレスポンスできる' do
        get :index, format: :csv
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('text/csv')
      end
    end

    context '一般ユーザーでログインしている場合' do
      before { sign_in normal_user }

      it '権限エラーが発生する' do
        expect { get :index }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされる' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #show' do
    before { sign_in admin_user }

    it '編集ページにリダイレクトされる' do
      get :show, params: { id: target_user.id }
      expect(response).to redirect_to(edit_user_path(target_user))
    end
  end

  describe 'GET #new' do
    context '管理者権限でログインしている場合' do
      before { sign_in admin_user }

      it '新規ユーザー作成フォームが表示される' do
        get :new
        expect(response).to have_http_status(:success)
        expect(assigns(:user)).to be_a_new(User)
        expect(assigns(:roles)).to eq(UserRole.roles)
      end
    end

    context '一般ユーザーでログインしている場合' do
      before { sign_in normal_user }

      it '権限エラーが発生する' do
        expect { get :new }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        user: {
          name: '新規ユーザー',
          email: 'new@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          began_on: Date.current,
          division: 'engineer'
        },
        user_roles: ['administrator']
      }
    end

    context '管理者権限でログインしている場合' do
      before { sign_in admin_user }

      it '正常なユーザー作成ができる' do
        expect do
          post :create, params: valid_params
        end.to change(User, :count).by(1)

        user = User.last
        expect(user.name).to eq('新規ユーザー')
        expect(user.email).to eq('new@example.com')
        expect(user.user_roles.pluck(:role)).to include('administrator')
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to include('新規ユーザーさんを登録しました。')
      end

      it '権限の設定ができる' do
        post :create, params: valid_params.merge(user_roles: ['director'])
        user = User.last
        expect(user.user_roles.pluck(:role)).to include('director')
      end

      it 'バリデーションエラー時は新規作成フォームを再表示する' do
        invalid_params = valid_params.deep_merge(user: { email: '' })
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(assigns(:roles)).to eq(UserRole.roles)
        expect(flash[:alert]).to include('ユーザーの登録に失敗しました。')
      end
    end

    context '一般ユーザーでログインしている場合' do
      before { sign_in normal_user }

      it '権限エラーが発生する' do
        post :create, params: valid_params
        expect(response).to render_template(:new)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #edit' do
    context '管理者権限でログインしている場合' do
      before { sign_in admin_user }

      it 'ユーザー編集フォームが表示される' do
        get :edit, params: { id: target_user.id }
        expect(response).to have_http_status(:success)
        expect(assigns(:user)).to eq(target_user)
        expect(assigns(:roles)).to eq(UserRole.roles)
      end
    end

    context '一般ユーザーの場合（自分自身も編集不可）' do
      before { sign_in normal_user }

      it '権限エラーが発生する' do
        expect { get :edit, params: { id: normal_user.id } }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context '他のユーザーを編集しようとする場合' do
      before { sign_in normal_user }

      it '権限エラーが発生する' do
        expect { get :edit, params: { id: target_user.id } }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'PATCH #update' do
    let(:update_params) do
      {
        id: target_user.id,
        user: {
          name: '更新されたユーザー',
          email: target_user.email,
          division: 'designer'
        },
        user_roles: ['director']
      }
    end

    context '管理者権限でログインしている場合' do
      before { sign_in admin_user }

      it '正常な更新ができる' do
        patch :update, params: update_params
        target_user.reload
        expect(target_user.name).to eq('更新されたユーザー')
        expect(target_user.division).to eq('designer')
        expect(target_user.user_roles.pluck(:role)).to include('director')
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to include('更新されたユーザーさんの設定を更新しました。')
      end

      it 'バリデーションエラー時は編集フォームを再表示する' do
        invalid_params = update_params.deep_merge(user: { email: '' })
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
        expect(assigns(:roles)).to eq(UserRole.roles)
        expect(flash[:alert]).to include('ユーザーの設定の更新に失敗しました。')
      end
    end

    context '一般ユーザーの場合（自分以外のユーザー編集）' do
      before { sign_in normal_user }

      it '権限エラーが発生する' do
        patch :update, params: update_params
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    context '管理者権限でログインしている場合' do
      before { sign_in admin_user }

      it '論理削除が実行される' do
        delete :destroy, params: { id: target_user.id }
        target_user.reload
        expect(target_user.deleted_at).not_to be_nil
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to include("#{target_user.name}さんを集計対象から外しました。")
      end
    end

    context '一般ユーザーでログインしている場合' do
      before { sign_in normal_user }

      it '権限エラーが発生する' do
        expect { delete :destroy, params: { id: target_user.id } }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'PATCH #revive' do
    let(:deleted_user) { create(:user, deleted_at: Time.current, email: 'deleted_revive@example.com') }

    context '管理者権限でログインしている場合' do
      before { sign_in admin_user }

      it '論理削除が解除される' do
        patch :revive, params: { id: deleted_user.id }
        deleted_user.reload
        expect(deleted_user.deleted_at).to be_nil
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to include("#{deleted_user.name}さんを集計対象に設定しました。")
      end
    end

    context '一般ユーザーでログインしている場合' do
      before { sign_in normal_user }

      it '権限エラーが発生する' do
        expect { patch :revive, params: { id: deleted_user.id } }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
