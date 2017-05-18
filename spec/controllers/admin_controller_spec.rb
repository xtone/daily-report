require 'rails_helper'

RSpec.describe AdminController, type: :controller do

  describe "GET #index" do
    context 'when not login' do
      it "redirected" do
        get :index
        expect(response).to redirect_to('/users/sign_in')
      end
    end
  end
end

