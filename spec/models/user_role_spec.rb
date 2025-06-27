require 'rails_helper'

RSpec.describe UserRole, type: :model do
  # アソシエーションテスト
  describe 'associations' do
    it { should have_many(:user_role_associations).dependent(:destroy) }
    it { should have_many(:users).through(:user_role_associations) }
  end

  # バリデーションテスト
  describe 'validations' do
    describe 'role' do
      it 'is required' do
        user_role = build(:user_role, role: nil)
        expect(user_role).not_to be_valid
        expect(user_role.errors[:role]).to be_present
      end
    end
  end

  # Enumテスト
  describe 'enums' do
    it 'defines role enum' do
      expect(UserRole.roles).to eq({
        'administrator' => 0,
        'director' => 1
      })
    end

    it 'creates administrator role' do
      user_role = create(:user_role, :administrator)
      expect(user_role.administrator?).to be true
      expect(user_role.director?).to be false
    end

    it 'creates director role' do
      user_role = create(:user_role, :director)
      expect(user_role.director?).to be true
      expect(user_role.administrator?).to be false
    end
  end

  # メソッドテスト
  describe 'role methods' do
    describe '#administrator?' do
      it 'returns true for administrator role' do
        user_role = create(:user_role, :administrator)
        expect(user_role.administrator?).to be true
      end

      it 'returns false for director role' do
        user_role = create(:user_role, :director)
        expect(user_role.administrator?).to be false
      end
    end

    describe '#director?' do
      it 'returns true for director role' do
        user_role = create(:user_role, :director)
        expect(user_role.director?).to be true
      end

      it 'returns false for administrator role' do
        user_role = create(:user_role, :administrator)
        expect(user_role.director?).to be false
      end
    end
  end
end
