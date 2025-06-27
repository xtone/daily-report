require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:report) { create(:report, user: user, worked_in: Date.current) }

  describe 'authentication' do
    context 'when user is not logged in' do
      it 'redirects to login page for index' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'returns unauthorized for create' do
        post :create, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'when user is logged in' do
    before { sign_in user }

    describe 'GET #index' do
      context 'with HTML format' do
        it 'returns success' do
          get :index
          expect(response).to have_http_status(:success)
        end

        it 'assigns @date' do
          get :index
          expect(assigns(:date)).to be_present
        end

        it 'assigns @projects' do
          create(:user_project, user: user, project: project)
          get :index
          expect(assigns(:projects)).to include(project)
        end

        it 'uses current date when no date param' do
          get :index
          expect(assigns(:date)).to eq(Time.zone.now.to_date)
        end

        it 'uses provided date param' do
          date_param = '202301'
          get :index, params: { date: date_param }
          expect(assigns(:date)).to eq(Date.new(2023, 1, 1))
        end
      end

      context 'with JSON format' do
        let!(:report1) { create(:report, user: user, worked_in: Date.current) }
        let!(:report2) { create(:report, user: user, worked_in: Date.current.beginning_of_month) }

        it 'returns reports for current week when no date param' do
          get :index, format: :json
          expect(response).to have_http_status(:success)
          expect(assigns(:reports)).to be_present
        end

        it 'returns reports for specified month when date param provided' do
          date_param = Date.current.strftime('%Y%m')
          get :index, params: { date: date_param }, format: :json
          expect(response).to have_http_status(:success)
          expect(assigns(:reports)).to be_present
        end
      end

      context 'with CSV format' do
        let!(:report1) { create(:report, user: user, worked_in: Date.current) }

        it 'redirects when start or end date is missing' do
          get :index, format: :csv
          expect(response).to redirect_to(admin_csvs_path)
          expect(flash[:alert]).to include('集計開始日と集計終了日を設定してください')
        end

        it 'redirects when start date is after end date' do
          get :index, params: {
            reports: {
              start: Date.current.to_s,
              end: Date.current.yesterday.to_s
            }
          }, format: :csv
          expect(response).to redirect_to(admin_csvs_path)
          expect(flash[:alert]).to include('集計開始日が集計終了日より後になっています')
        end

        it 'generates CSV when valid date range provided' do
          get :index, params: {
            reports: {
              start: Date.current.beginning_of_month.to_s,
              end: Date.current.end_of_month.to_s
            }
          }, format: :csv
          expect(response).to have_http_status(:success)
          expect(response.content_type).to include('text/csv')
        end
      end
    end

    describe 'POST #create' do
      context 'with JSON format' do
        let(:valid_params) {
          {
            worked_in: Date.current.to_s,
            project_ids: [project.id.to_s],
            workloads: ['100']
          }
        }

        it 'creates a new report' do
          expect {
            post :create, params: valid_params, format: :json
          }.to change(Report, :count).by(1)
        end

        it 'creates operations for the report' do
          expect {
            post :create, params: valid_params, format: :json
          }.to change(Operation, :count).by(1)
        end

        it 'returns success' do
          post :create, params: valid_params, format: :json
          expect(response).to have_http_status(:success)
        end

        it 'skips blank project_ids and workloads' do
          params_with_blanks = {
            worked_in: Date.current.to_s,
            project_ids: [project.id.to_s, ''],
            workloads: ['50', '']
          }
          expect {
            post :create, params: params_with_blanks, format: :json
          }.to change(Operation, :count).by(1)
        end
      end
    end

    describe 'PUT #update' do
      let!(:operation) { create(:operation, report: report, project: project, workload: 50) }

      context 'with JSON format' do
        let(:update_params) {
          {
            id: report.id,
            operation_ids: [operation.id.to_s],
            project_ids: [project.id.to_s],
            workloads: ['75']
          }
        }

        it 'updates the report operations' do
          put :update, params: update_params, format: :json
          expect(response).to have_http_status(:success)
          expect(operation.reload.workload).to eq(75)
        end

        it 'creates new operations when operation_id is blank' do
          new_project = create(:project, code: 99999)
          params_with_new_op = {
            id: report.id,
            operation_ids: [operation.id.to_s, ''],
            project_ids: [project.id.to_s, new_project.id.to_s],
            workloads: ['50', '25']
          }
          expect {
            put :update, params: params_with_new_op, format: :json
          }.to change(Operation, :count).by(1)
        end
      end

      context 'when user is not authorized' do
        let(:other_user) { create(:user, email: 'other@example.com') }
        let(:other_report) { create(:report, user: other_user) }

        it 'raises Pundit::NotAuthorizedError' do
          expect {
            put :update, params: { id: other_report.id }, format: :json
          }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:operation) { create(:operation, report: report, project: project) }

      context 'with JSON format' do
        it 'destroys the report' do
          expect {
            delete :destroy, params: { id: report.id }, format: :json
          }.to change(Report, :count).by(-1)
        end

        it 'returns success' do
          delete :destroy, params: { id: report.id }, format: :json
          expect(response).to have_http_status(:success)
        end
      end

      context 'when user is not authorized' do
        let(:other_user) { create(:user, email: 'other@example.com') }
        let(:other_report) { create(:report, user: other_user) }

        it 'raises Pundit::NotAuthorizedError' do
          expect {
            delete :destroy, params: { id: other_report.id }, format: :json
          }.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end
  end
end
