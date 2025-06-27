require 'rails_helper'

RSpec.describe Reports::UnsubmittedsController, type: :controller do
  let(:admin_user) { create(:user, :administrator, email: 'admin_unsubmitteds@example.com') }
  let(:director_user) { create(:user, :director, email: 'director_unsubmitteds@example.com') }
  let(:regular_user) { create(:user, email: 'regular_unsubmitteds@example.com') }
  let(:start_date) { Date.new(2023, 1, 1) }
  let(:end_date) { Date.new(2023, 1, 31) }

  describe 'authorization' do
    context 'when user is not logged in' do
      it 'redirects to login page' do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when regular user is logged in' do
      before { sign_in regular_user }

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          get :show
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'when authorized user is logged in' do
    before { sign_in admin_user }

    describe 'GET #show' do
      it 'returns success' do
        get :show
        expect(response).to have_http_status(:success)
      end

      it 'assigns default date range when no params' do
        get :show
        expect(assigns(:start_date)).to be_present
        expect(assigns(:end_date)).to be_present
      end

      context 'with valid date parameters' do
        let(:params) {
          {
            reports: {
              start: start_date.to_s,
              end: end_date.to_s
            }
          }
        }

        it 'assigns date range from params' do
          get :show, params: params
          expect(assigns(:start_date)).to eq(start_date)
          expect(assigns(:end_date)).to eq(end_date)
        end

        it 'assigns unsubmitted data' do
          get :show, params: params
          expect(assigns(:data)).to be_present
        end

        it 'includes users with unsubmitted dates' do
          # ユーザーに未提出日がある場合のテスト
          allow(Report).to receive(:unsubmitted_dates).and_return([Date.new(2023, 1, 10)])
          get :show, params: params
          expect(assigns(:data)).to be_an(Array)
        end

        it 'excludes users without unsubmitted dates' do
          # 全て提出済みのユーザーは除外される
          allow(Report).to receive(:unsubmitted_dates).and_return([])
          get :show, params: params
          expect(assigns(:data)).to be_empty
        end
      end

      context 'with invalid date range' do
        let(:invalid_params) {
          {
            reports: {
              start: end_date.to_s,
              end: start_date.to_s
            }
          }
        }

        it 'shows error message when start date is after end date' do
          get :show, params: invalid_params
          expect(flash.now[:alert]).to eq('集計開始日が集計終了日より後になっています。')
        end

        it 'does not assign data when date range is invalid' do
          get :show, params: invalid_params
          expect(assigns(:data)).to be_nil
        end
      end
    end
  end

  describe 'when director user is logged in' do
    before { sign_in director_user }

    it 'allows access to show action' do
      get :show
      expect(response).to have_http_status(:success)
    end
  end
end 