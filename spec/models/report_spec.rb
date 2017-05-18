require 'rails_helper'

RSpec.describe Report, type: :model do
  let(:user) { create :user }
  let(:pj1) { create :project, name: 'PJ1' }
  let(:pj2) { create :project, name: 'PJ2' }
  let(:report1) { create :report, user_id: user.id, worked_in: '2017-01-13' }

  describe '.find_in_month' do
    let!(:op1) { create :operation, report_id: report1.id, project_id: pj1.id, workload: 60 }
    let!(:op2) { create :operation, report_id: report1.id, project_id: pj2.id, workload: 40 }
    subject { Report.find_in_month(user.id, at) }

    context 'in 2017-01' do
      let(:at) { Time.zone.local(2017, 1, 13) }
      it 'report exists.' do
        data = subject
        expect(data.size).to eq 31
        expect(data[12][:date]).to eq(Date.new(2017, 1, 13))
        expect(data[12][:report]).to eq(report1)
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
    let!(:op1) { create :operation, report_id: report1.id, project_id: pj1.id, workload: 60 }
    let!(:op2) { create :operation, report_id: report1.id, project_id: pj2.id, workload: 40 }
    subject { Report.find_in_week(user.id, at) }

    context 'at 2017-01-10' do
      let(:at) { Time.zone.local(2017, 1, 13) }
      it do
        data = subject
        expect(data.size).to eq 7
        expect(data[4][:date]).to eq(Date.new(2017, 1, 13))
        expect(data[4][:report]).to eq(report1)
      end
    end
  end

  describe '.submitted_users' do
    let!(:op1) { create :operation, report_id: report1.id, project_id: pj1.id, workload: 60 }
    let!(:op2) { create :operation, report_id: report1.id, project_id: pj2.id, workload: 40 }
    subject { Report.submitted_users(start_on, end_on) }

    context 'within the period' do
      let(:start_on) { Date.new(2017, 1, 1) }
      let(:end_on) { Date.new(2017, 1, 31) }
      it 'should find user.' do
        #users = subject
        #expect(users.count).to eq 1
        #expect(users.first).to eq(user)
      end
    end

    context 'out of period' do
      let(:start_on) { Date.new(2017, 2, 1) }
      let(:end_on) { Date.new(2017, 2, 28) }
      it 'should not find user.' do
        #users = subject
        #expect(users.count).to eq 0
      end
    end
  end
end
