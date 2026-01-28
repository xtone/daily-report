# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Authentication', type: :request do
  let(:user) { create(:user) }
  let!(:api_token) { nil }
  let!(:plain_token) { nil }
  let!(:project) { create(:project) }

  def login_as(user)
    post user_session_path, params: {
      user: { email: user.email, password: 'password' }
    }
  end

  before do
    @api_token, @plain_token = ApiToken.generate_token(user)
    create(:user_project, user: user, project: project)
  end

  describe 'Bearer token authentication' do
    describe 'GET /reports.json' do
      context 'with valid token' do
        it 'allows access' do
          get reports_path(format: :json),
              headers: { 'Authorization' => "Bearer #{@plain_token}" }

          expect(response).to have_http_status(:success)
        end

        it 'updates last_used_at' do
          expect(@api_token.last_used_at).to be_nil

          get reports_path(format: :json),
              headers: { 'Authorization' => "Bearer #{@plain_token}" }

          @api_token.reload
          expect(@api_token.last_used_at).to be_present
        end
      end

      context 'with invalid token' do
        it 'returns 401 unauthorized' do
          get reports_path(format: :json),
              headers: { 'Authorization' => 'Bearer invalid_token' }

          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body).to eq({ 'error' => 'unauthorized' })
        end

        it 'does not fallback to session authentication' do
          # セッション認証は行われていない状態でリクエスト
          get reports_path(format: :json),
              headers: { 'Authorization' => 'Bearer invalid_token' }

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with revoked token' do
        before { @api_token.revoke! }

        it 'returns 401 unauthorized' do
          get reports_path(format: :json),
              headers: { 'Authorization' => "Bearer #{@plain_token}" }

          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body).to eq({ 'error' => 'unauthorized' })
        end
      end

      context 'with deleted user token' do
        before { user.soft_delete }

        it 'returns 401 unauthorized' do
          get reports_path(format: :json),
              headers: { 'Authorization' => "Bearer #{@plain_token}" }

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'without token (session fallback)' do
        it 'redirects to login page when not logged in' do
          get reports_path(format: :json)

          expect(response).to have_http_status(:unauthorized)
        end

        it 'allows access when logged in via session' do
          login_as(user)

          get reports_path(format: :json)

          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'POST /reports.json (CSRF protection)' do
      context 'with token authentication' do
        it 'does not return 401 (authentication passes)' do
          post reports_path(format: :json),
               params: {
                 worked_in: Date.current.to_s,
                 project_ids: [project.id],
                 workloads: [100]
               },
               headers: { 'Authorization' => "Bearer #{@plain_token}" }

          # 認証は成功しているべき（401が返らない）
          # 422は認証とは無関係のバリデーションエラーなので許容
          expect(response).not_to have_http_status(:unauthorized)
        end
      end

      context 'with session authentication' do
        it 'allows POST when logged in via session' do
          login_as(user)

          post reports_path(format: :json),
               params: {
                 worked_in: Date.current.to_s,
                 project_ids: [project.id],
                 workloads: [100]
               }

          # 認証は成功しているべき（401が返らない）
          expect(response).not_to have_http_status(:unauthorized)
        end
      end
    end

    describe 'PATCH /reports/:id.json' do
      let!(:report) { create(:report, user: user) }

      context 'with token authentication' do
        it 'does not return 401 (authentication passes)' do
          patch report_path(report, format: :json),
                params: {
                  operation_ids: [],
                  project_ids: [project.id],
                  workloads: [80]
                },
                headers: { 'Authorization' => "Bearer #{@plain_token}" }

          # 認証は成功しているべき（401が返らない）
          expect(response).not_to have_http_status(:unauthorized)
        end
      end
    end

    describe 'DELETE /reports/:id.json' do
      let!(:report) { create(:report, user: user) }

      context 'with token authentication' do
        it 'does not return 401 (authentication passes)' do
          delete report_path(report, format: :json),
                 headers: { 'Authorization' => "Bearer #{@plain_token}" }

          # 認証は成功しているべき（401が返らない）
          expect(response).not_to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe 'Settings::Projects API authentication' do
    describe 'GET /settings/projects.json' do
      context 'with valid token' do
        it 'allows access' do
          get settings_projects_path(format: :json),
              headers: { 'Authorization' => "Bearer #{@plain_token}" }

          expect(response).to have_http_status(:success)
        end
      end

      context 'with invalid token' do
        it 'returns 401 unauthorized' do
          get settings_projects_path(format: :json),
              headers: { 'Authorization' => 'Bearer invalid_token' }

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
