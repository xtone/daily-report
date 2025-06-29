require 'rails_helper'

RSpec.describe Report, type: :model do
  let(:user) { create(:user) }
  let(:pj1) { create(:project, name: 'PJ1') }
  let(:pj2) { create(:project, name: 'PJ2') }
  let(:report1) { create(:report, user_id: user.id, worked_in: '2017-01-13') }

  # バリデーションテスト
  describe 'validations' do
    describe 'worked_in' do
      it 'is required' do
        report = build(:report, worked_in: nil)
        expect(report).not_to be_valid
        expect(report.errors[:worked_in]).to include('を入力してください')
      end
    end
  end

  # アソシエーションテスト
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:operations) }
    it { is_expected.to have_many(:projects).through(:operations) }

    it 'has autosave enabled for operations' do
      expect(Report.reflect_on_association(:operations).options[:autosave]).to be true
    end
  end

  describe '.find_in_month' do
    subject { Report.find_in_month(user.id, at) }

    let!(:op1) { create(:operation, report_id: report1.id, project_id: pj1.id, workload: 60) }
    let!(:op2) { create(:operation, report_id: report1.id, project_id: pj2.id, workload: 40) }

    context 'in 2017-01' do
      let(:at) { Time.zone.local(2017, 1, 13) }

      it 'report exists.' do
        data = subject
        expect(data.size).to eq 31
        expect(data[12][:date]).to eq(Date.new(2017, 1, 13))
        expect(data[12][:report]).to eq(report1)
      end

      it 'includes holiday information' do
        # 1月1日は元日
        data = subject
        expect(data[0][:date]).to eq(Date.new(2017, 1, 1))
        expect(data[0][:holiday]).to be_truthy
      end
    end

    context 'not in 2017-01' do
      let(:at) { Time.zone.local(2017, 2, 13) }

      it 'no report exists.' do
        data = subject
        expect(data.size).to eq 28
        expect(data[12][:date]).to eq(Date.new(2017, 2, 13))
        expect(data[12][:report]).to eq(nil)
      end
    end
  end

  describe '.find_in_week' do
    subject { Report.find_in_week(user.id, at) }

    let!(:op1) { create(:operation, report_id: report1.id, project_id: pj1.id, workload: 60) }
    let!(:op2) { create(:operation, report_id: report1.id, project_id: pj2.id, workload: 40) }

    context 'at 2017-01-13' do
      let(:at) { Time.zone.local(2017, 1, 13) }

      it 'returns 7 days of data' do
        data = subject
        expect(data.size).to eq 7
        expect(data[0][:date]).to eq(Date.new(2017, 1, 9))  # 4 days before
        expect(data[4][:date]).to eq(Date.new(2017, 1, 13))
        expect(data[4][:report]).to eq(report1)
        expect(data[6][:date]).to eq(Date.new(2017, 1, 15)) # 2 days after
      end
    end
  end

  describe '.submitted_users' do
    subject { Report.submitted_users(start_on, end_on) }

    let!(:op1) { create(:operation, report_id: report1.id, project_id: pj1.id, workload: 60) }
    let!(:op2) { create(:operation, report_id: report1.id, project_id: pj2.id, workload: 40) }
    let!(:user2) { create(:user, email: 'user2@example.com') }
    let!(:report2) { create(:report, user_id: user2.id, worked_in: '2017-01-15') }
    let!(:op3) { create(:operation, report_id: report2.id, project_id: pj1.id, workload: 100) }

    context 'within the period' do
      let(:start_on) { Date.new(2017, 1, 1) }
      let(:end_on) { Date.new(2017, 1, 31) }

      it 'finds users.' do
        users = subject
        expect(users.count).to eq 2
        expect(users).to include(user)
        expect(users).to include(user2)
      end
    end

    context 'out of period' do
      let(:start_on) { Date.new(2017, 2, 1) }
      let(:end_on) { Date.new(2017, 2, 28) }

      it 'does not find user.' do
        users = subject
        expect(users.count).to eq 0
      end
    end

    context 'with deleted user' do
      let!(:deleted_user) { create(:user, :deleted, email: 'deleted@example.com') }
      let!(:report3) { create(:report, user_id: deleted_user.id, worked_in: '2017-01-20') }
      let!(:op4) { create(:operation, report_id: report3.id, project_id: pj1.id, workload: 100) }
      let(:start_on) { Date.new(2017, 1, 1) }
      let(:end_on) { Date.new(2017, 1, 31) }

      it 'excludes deleted users' do
        users = subject
        expect(users).not_to include(deleted_user)
        expect(users.count).to eq 2
      end
    end
  end

  describe '.unsubmitted_dates' do
    subject { Report.unsubmitted_dates(user.id, start_on: start_on, end_on: end_on) }

    before do
      # 2017-01-13 (金曜日) のレポートは既に存在
      report1
    end

    context 'with weekdays only' do
      let(:start_on) { Date.new(2017, 1, 10) } # 火曜日
      let(:end_on) { Date.new(2017, 1, 20) }   # 金曜日

      it 'returns unsubmitted weekdays' do
        dates = subject
        # 1/10(火), 1/11(水), 1/12(木), 1/16(月), 1/17(火), 1/18(水), 1/19(木), 1/20(金)
        # 1/13(金)は提出済み, 1/14(土), 1/15(日)は週末
        expect(dates.size).to eq 8 # 1/10, 1/11, 1/12, 1/16, 1/17, 1/18, 1/19, 1/20
        expect(dates).not_to include(Date.new(2017, 1, 13)) # 提出済み
        expect(dates).not_to include(Date.new(2017, 1, 14)) # 土曜日
        expect(dates).not_to include(Date.new(2017, 1, 15)) # 日曜日
      end
    end

    context 'with holidays' do
      let(:start_on) { Date.new(2017, 1, 1) }
      let(:end_on) { Date.new(2017, 1, 10) }

      it 'excludes holidays' do
        dates = subject
        # 1/1(日)元日, 1/2(月)振替休日, 1/7(土), 1/8(日), 1/9(月)成人の日は除外
        expect(dates).not_to include(Date.new(2017, 1, 1))  # 元日
        expect(dates).not_to include(Date.new(2017, 1, 2))  # 振替休日
        expect(dates).not_to include(Date.new(2017, 1, 9))  # 成人の日
      end
    end

    context 'before user began_on' do
      let(:start_on) { Date.new(2016, 12, 1) }
      let(:end_on) { Date.new(2017, 1, 10) }

      it 'ignores dates before user began_on' do
        dates = subject
        expect(dates.all? { |d| d >= user.began_on }).to be true
      end
    end

    context 'with nil began_on' do
      before do
        user.update_column(:began_on, nil)
      end

      let(:start_on) { Date.new(2017, 1, 1) }
      let(:end_on) { Date.new(2017, 1, 10) }

      it 'returns empty array' do
        expect(subject).to eq []
      end
    end
  end

  describe '.output_calendar (private method)' do
    it 'is tested through find_in_month and find_in_week' do
      # このプライベートメソッドは find_in_month と find_in_week を通じてテストされています
    end
  end
end
