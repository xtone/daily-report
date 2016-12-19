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
      calendar = []
      base = date.beginning_of_month.to_date
      date.end_of_month.day.times do |mday|
        d = base + mday
        calendar << {
          date: d,
          holiday: d.holiday?(:jp),
          report: data.find { |report| report.worked_in == d }
        }
      end
      calendar
    end
  end
end
