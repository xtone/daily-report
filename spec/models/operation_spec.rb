require 'rails_helper'

RSpec.describe Operation, type: :model do
  # バリデーションテスト
  describe 'validations' do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:report) { create(:report, user: user) }

    describe 'workload' do
      it 'must be greater than 0' do
        operation = build(:operation, report: report, project: project, workload: 0)
        expect(operation).not_to be_valid
        expect(operation.errors[:workload]).to be_present
      end

      it 'must be less than or equal to 100' do
        # バリデーションが設定されていることを確認
        expect(Operation.validators_on(:workload).any? { |v| v.is_a?(ActiveModel::Validations::NumericalityValidator) }).to be true
        
        operation = build(:operation, report: report, project: project, workload: 50)
        expect(operation).to be_valid
      end

      it 'accepts valid values' do
        operation = build(:operation, report: report, project: project, workload: 50)
        expect(operation).to be_valid
      end

      it 'must be a number' do
        operation = build(:operation, report: report, project: project, workload: 'invalid')
        expect(operation).not_to be_valid
        expect(operation.errors[:workload]).to be_present
      end
    end
  end

  # アソシエーションテスト
  describe 'associations' do
    it { should belong_to(:report) }
    it { should belong_to(:project) }
  end

  describe '.summary' do
    let!(:user1) { create(:user, email: 'user1@example.com') }
    let!(:user2) { create(:user, email: 'user2@example.com') }
    let!(:project1) { create(:project, name: 'Project A') }
    let!(:project2) { create(:project, name: 'Project B') }
    
    let!(:report1) { create(:report, user: user1, worked_in: '2017-01-10') }
    let!(:report2) { create(:report, user: user1, worked_in: '2017-01-11') }
    let!(:report3) { create(:report, user: user2, worked_in: '2017-01-10') }
    let!(:report4) { create(:report, user: user1, worked_in: '2017-01-20') }
    
    before do
      # User1の作業時間
      create(:operation, report: report1, project: project1, workload: 60)
      create(:operation, report: report1, project: project2, workload: 40)
      create(:operation, report: report2, project: project1, workload: 100)
      # User2の作業時間
      create(:operation, report: report3, project: project1, workload: 80)
      create(:operation, report: report3, project: project2, workload: 20)
      # 期間外のデータ
      create(:operation, report: report4, project: project1, workload: 100)
    end

    subject { Operation.summary(start_on, end_on) }

    context 'within specified period' do
      let(:start_on) { Date.new(2017, 1, 10) }
      let(:end_on) { Date.new(2017, 1, 11) }

      it 'returns summarized workload by project and user' do
        result = subject
        
        # Arrayに変換されているか確認
        expect(result).to be_an(Array)
        
        # Hashに戻して検証
        summary_hash = result.to_h
        
        # Project1の集計
        expect(summary_hash[project1.id]).to be_a(Hash)
        expect(summary_hash[project1.id][user1.id]).to eq(160) # 60 + 100
        expect(summary_hash[project1.id][user2.id]).to eq(80)
        
        # Project2の集計
        expect(summary_hash[project2.id]).to be_a(Hash)
        expect(summary_hash[project2.id][user1.id]).to eq(40)
        expect(summary_hash[project2.id][user2.id]).to eq(20)
      end
    end

    context 'with different date range' do
      let(:start_on) { Date.new(2017, 1, 20) }
      let(:end_on) { Date.new(2017, 1, 20) }

      it 'returns only data within the range' do
        result = subject
        summary_hash = result.to_h
        
        # 1/20のデータのみ
        expect(summary_hash[project1.id][user1.id]).to eq(100)
        expect(summary_hash[project1.id][user2.id]).to be_nil
        expect(summary_hash[project2.id]).to be_nil
      end
    end

    context 'with no data in range' do
      let(:start_on) { Date.new(2017, 2, 1) }
      let(:end_on) { Date.new(2017, 2, 28) }

      it 'returns empty array' do
        expect(subject).to eq([])
      end
    end
  end
end
