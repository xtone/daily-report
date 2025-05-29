require 'rails_helper'

RSpec.describe UserProject, type: :model do
  # アソシエーションテスト
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:project) }
  end

  # バリデーションテスト
  describe 'validations' do
    describe 'user_id' do
      it 'is required' do
        user_project = build(:user_project, user: nil)
        expect(user_project).not_to be_valid
        expect(user_project.errors[:user_id]).to be_present
      end
    end

    describe 'project_id' do
      it 'is required' do
        user_project = build(:user_project, project: nil)
        expect(user_project).not_to be_valid
        expect(user_project.errors[:project_id]).to be_present
      end
    end
  end

  # ユニーク制約のテスト
  describe 'uniqueness constraints' do
    let!(:user) { create(:user) }
    let!(:project) { create(:project) }

    it 'allows unique user_id and project_id combination' do
      user_project = build(:user_project, user: user, project: project)
      expect(user_project).to be_valid
    end

    it 'prevents duplicate user_id and project_id combination' do
      create(:user_project, user: user, project: project)
      duplicate_user_project = build(:user_project, user: user, project: project)
      expect(duplicate_user_project).not_to be_valid
      expect(duplicate_user_project.errors[:user_id]).to be_present
    end

    it 'allows same user with different projects' do
      project2 = create(:project, code: 99999)
      create(:user_project, user: user, project: project)
      user_project2 = build(:user_project, user: user, project: project2)
      expect(user_project2).to be_valid
    end

    it 'allows same project with different users' do
      user2 = create(:user, email: 'user2@example.com')
      create(:user_project, user: user, project: project)
      user_project2 = build(:user_project, user: user2, project: project)
      expect(user_project2).to be_valid
    end
  end
end
