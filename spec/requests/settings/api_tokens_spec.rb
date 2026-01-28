# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings::ApiTokens', type: :request do
  let(:user) { create(:user) }

  def login_as(user)
    post user_session_path, params: {
      user: { email: user.email, password: 'password' }
    }
  end

  describe 'GET /settings/api_tokens' do
    context 'ログイン済みの場合' do
      before { login_as(user) }

      it 'APIトークン管理画面が表示される' do
        get settings_api_tokens_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('APIトークン管理')
      end

      context 'トークンが存在する場合' do
        let!(:api_token) { create(:api_token, user: user, name: 'Test Token') }
        let!(:revoked_token) { create(:api_token, :revoked, user: user, name: 'Revoked Token') }

        it 'トークン一覧が表示される' do
          get settings_api_tokens_path
          expect(response.body).to include('Test Token')
          expect(response.body).to include('Revoked Token')
        end
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされる' do
        get settings_api_tokens_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /settings/api_tokens' do
    context 'ログイン済みの場合' do
      before { login_as(user) }

      it 'トークンが生成される' do
        expect do
          post settings_api_tokens_path, params: {
            api_token: { name: 'New Token' }
          }
        end.to change(ApiToken, :count).by(1)

        expect(response).to redirect_to(settings_api_tokens_path)
        expect(flash[:notice]).to eq('APIトークンを生成しました。')
      end

      it '生成されたトークンが一度だけ表示される' do
        post settings_api_tokens_path, params: {
          api_token: { name: 'New Token' }
        }

        expect(flash[:plain_token]).to be_present
        plain_token = flash[:plain_token]

        # リダイレクト後のページを取得
        follow_redirect!
        expect(response.body).to include(plain_token)
        expect(response.body).to include('このトークンは二度と表示されません')

        # 再度アクセスすると表示されない
        get settings_api_tokens_path
        expect(response.body).not_to include(plain_token)
      end

      it '名前が空の場合はデフォルト名が使用される' do
        post settings_api_tokens_path, params: {
          api_token: { name: '' }
        }

        expect(ApiToken.last.name).to eq('Default')
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされる' do
        post settings_api_tokens_path, params: {
          api_token: { name: 'New Token' }
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE /settings/api_tokens/:id' do
    let!(:api_token) { create(:api_token, user: user) }

    context 'ログイン済みの場合' do
      before { login_as(user) }

      it 'トークンが失効する（物理削除されない）' do
        expect do
          delete settings_api_token_path(api_token)
        end.not_to change(ApiToken, :count)

        api_token.reload
        expect(api_token.revoked_at).to be_present
        expect(response).to redirect_to(settings_api_tokens_path)
        expect(flash[:notice]).to eq('APIトークンを失効しました。')
      end

      it '他のユーザーのトークンは失効できない' do
        other_user = create(:user)
        other_token = create(:api_token, user: other_user)

        delete settings_api_token_path(other_token)
        # 他のユーザーのトークンにはアクセスできない
        expect(response).to have_http_status(:not_found)
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされる' do
        delete settings_api_token_path(api_token)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
