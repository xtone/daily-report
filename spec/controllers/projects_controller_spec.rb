RSpec.describe ProjectsController, type: :controller do
  let(:user) {create(:user, :administrator)}
  let(:project) {create(:project, :with_user_project)}

  describe "delete #destroy" do
    before do
      sign_in user
      delete :destroy, params: {id: project.id}
    end

    context 'project registerd to user_project table' do
      subject {Project.find_by(id: project.id)}
      it {is_expected.to be_present}

    end

    context 'project Not registerd to user_project table' do
      let(:project) {create(:project)}
      subject {Project.find_by(id: project.id)}
      it {is_expected.not_to be_present}
    end
  end
end
