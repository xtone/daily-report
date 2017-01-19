require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#administrator?' do
    subject { user.administrator? }

    context 'user is administrator' do
      let(:user) { create :user, :administrator }
      it 'should return true' do
        is_expected.to eq(true)
      end
    end

    context 'user is not administrator' do
      let(:user) { create :user }
      it 'should return false' do
        is_expected.to eq(false)
      end
    end
  end

  describe '#general_affairs?' do
    subject { user.general_affairs? }

    context 'user is general_affairs' do
      let(:user) { create :user, :general_affairs }
      it 'should return true' do
        is_expected.to eq(true)
      end
    end

    context 'user is not general_affairs' do
      let(:user) { create :user }
      it 'should return false' do
        is_expected.to eq(false)
      end
    end
  end

  describe '#director?' do
    subject { user.director? }

    context 'user is director' do
      let(:user) { create :user, :director }
      it 'should return true' do
        is_expected.to eq(true)
      end
    end

    context 'user is not director' do
      let(:user) { create :user }
      it 'should return false' do
        is_expected.to eq(false)
      end
    end
  end

  describe '#available?' do
    subject { user.available? }

    context 'user is not deleted' do
      let(:user) { create :user }
      it 'should return true' do
        is_expected.to eq(true)
      end
    end

    context 'user is deleted' do
      let(:user) { create :user, :deleted }
      it 'should return false' do
        is_expected.to eq(false)
      end
    end
  end

  describe '#soft_delete' do
    subject { user.soft_delete }
    let(:user) { create :user }
    it {
      subject
      expect(user.available?).to eq(false)
    }
  end

  describe '#revive' do
    subject { user.revive }
    let(:user) { create :user, :deleted }
    it {
      subject
      expect(user.available?).to eq(true)
    }
  end
end
