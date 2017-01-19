class Operation < ApplicationRecord
  belongs_to :report
  belongs_to :project

  validates :workload,
    numericality: { greater_than: 0, less_than_or_equal: 100 }

  class << self
    # 指定した期間内に提出された日報を集計した結果を返す
    # @param [Date] start_on
    # @param [Date] end_on
    # @return [Array]
    def summary(start_on, end_on)
      includes(report: :user)
        .includes(:project)
        .references(:report)
        .where(reports: { worked_in: start_on..end_on })
        .group(:project_id, 'reports.user_id')
        .sum(:workload)
        .inject({}) { |result, (keys, value)|
          project_id, user_id = keys
          result[project_id] ||= {}
          result[project_id][user_id] = value
          result
        }.to_a
    end
  end
end
