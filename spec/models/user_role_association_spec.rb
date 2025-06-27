require 'rails_helper'

RSpec.describe UserRoleAssociation, type: :model do
  # アソシエーションテスト
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:user_role) }
  end

  # バリデーションテスト
  describe 'validations' do
    describe 'uniqueness constraints' do
      let!(:user) { create(:user) }
      let!(:user_role) { create(:user_role, :administrator) }

      it 'allows unique user_id and user_role_id combination' do
        association = build(:user_role_association, user: user, user_role: user_role)
        expect(association).to be_valid
      end

      it 'prevents duplicate user_id and user_role_id combination' do
        create(:user_role_association, user: user, user_role: user_role)
        duplicate_association = build(:user_role_association, user: user, user_role: user_role)
        expect(duplicate_association).not_to be_valid
        expect(duplicate_association.errors[:user_id]).to be_present
      end

      it 'allows same user with different roles' do
        director_role = create(:user_role, :director)
        create(:user_role_association, user: user, user_role: user_role)
        association2 = build(:user_role_association, user: user, user_role: director_role)
        expect(association2).to be_valid
      end

      it 'allows same role with different users' do
        user2 = create(:user, email: 'user2@example.com')
        create(:user_role_association, user: user, user_role: user_role)
        association2 = build(:user_role_association, user: user2, user_role: user_role)
        expect(association2).to be_valid
      end
    end
  end
end
