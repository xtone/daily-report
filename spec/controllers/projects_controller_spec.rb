RSpec.describe ProjectsController, type: :controller do
  let!(:user) {create(:user, :administrator)}
  let!(:project) {create(:project)}

  describe "delete #destroy" do
    before do
      sign_in user
    end

    context 'project registerd to user_project table' do
      before do
        create(:user_project, user_id: user.id, project_id: project.id)
        delete :destroy, params: {id: project.id}
      end

      subject {Project.find_by(id: project.id)}
      it {is_expected.to be_present}

    end

    context 'project Not registerd to user_project table' do
      before do
        delete :destroy, params: {id: project.id}
      end

      subject {Project.find_by(id: project.id)}
      it {is_expected.not_to be_present}
    end
  end
end
