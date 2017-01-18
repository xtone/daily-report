require 'rails_helper'

RSpec.describe Report, type: :model do
  let(:user) { create :user }
  let(:pj1) { create :project, name: 'PJ1' }
  let(:pj2) { create :project, name: 'PJ2' }
  let(:report1) { create :report, user_id: user.id, worked_in: '2017-01-13' }
  let!(:op1) { create :operation, report_id: report1.id, project_id: pj1.id, workload: 60 }
  let!(:op2) { create :operation, report_id: report1.id, project_id: pj2.id, workload: 40 }

  describe '.find_in_month' do
    subject { Report.find_in_month(user.id, at) }

    context 'in 2017-01' do
      let(:at) { Time.zone.local(2017, 1, 13) }
      it do
        data = subject
      end
    end

    context 'not in 2017-01' do
      let(:at) { Time.zone.local(2017, 2, 13) }
    end
  end

  describe '.find_in_week' do
    subject { Report.find_in_week(user.id, at) }
  end
end
