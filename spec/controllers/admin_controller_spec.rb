require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  describe 'GET #index' do
    context 'when not login' do
      it 'redirected' do
        get :index
        expect(response).to redirect_to('/users/sign_in')
      end
    end

    context 'when logged in as admin' do
      let(:admin_user) { create(:user, :administrator) }

      before do
        sign_in admin_user
      end

      it 'displays the admin dashboard' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'includes project management link with active and order parameters' do
        get :index
        expect(response.body).to include('href="/projects?active=true&amp;order=code_desc"')
      end
    end
  end
end
