require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  let(:user){create(:user, :administrator)}

  describe "delete #destroy" do
    before do
      sign_in user
    end

    context 'UNABLE to delete project registerd' do
      let!(:project){create(:project)}
      let!(:user_project){create(:user_project,user_id: user.id, project_id: project.id)}

      it "not delete the project " do
        expect do
          delete :destroy, params: { id: project.id}
        end.to change(Project,:count).by(0)
      end
    end
    context 'ABLE to delete the project NOT registered' do
      let!(:project){create(:project)}
      it "delete the project " do
        expect do
          delete :destroy, params: { id: project.id}
        end.to change(Project,:count).by(-1)
      end
    end
  end
end
