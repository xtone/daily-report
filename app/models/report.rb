class Report < ApplicationRecord
  belongs_to :user
  has_many :operations, autosave: true
  has_many :projects, through: :operations

  validates :worked_in,
    presence: true

  class << self
    # 日報のデータを月単位で取得する
    # @param [Integer] user_id
    # @param [Time] date
    # @return [Array]
    def find_in_month(user_id, date = Time.zone.now)
      data = includes(operations: :project)
               .where(user_id: user_id, worked_in: [date.beginning_of_month..date.end_of_month])
               .order(worked_in: :asc)
               .to_a
      output(data, date.beginning_of_month.to_date, date.end_of_month.day)
    end

    def find_in_week(user_id, at = Time.zone.now)
      base_date = at.to_date - 3
      data = includes(operations: :project)
               .where(user_id: user_id, worked_in: [base_date..(base_date + 6)])
               .order(worked_in: :asc)
               .to_a
      output(data, base_date, 7)
    end

    # start_onの日から数えてdays日数分のReportのデータを返す
    # @param [Array] data
    # @param [Date] start_on
    # @param [Integer] days
    # @return [Array]
    def output(data, start_on, days)
      ary = []
      days.times do |i|
        d = start_on + i
        ary << {
          date: d,
          holiday: d.holiday?(:jp),
          report: data.find{ |report| report.worked_in == d }
        }
      end
      ary
    end
  end
end
