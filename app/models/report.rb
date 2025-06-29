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
             .where(user_id: user_id, worked_in: [date.all_month])
             .order(worked_in: :asc)
             .to_a
      output_calendar(data, date.beginning_of_month.to_date, date.end_of_month.day)
    end

    # 日報のデータを7日分取得する
    # @param [Integer] user_id
    # @param [Time] at
    # @return [Array]
    def find_in_week(user_id, at = Time.zone.now)
      base_date = at.to_date - 4
      data = includes(operations: :project)
             .where(user_id: user_id, worked_in: [base_date..(base_date + 6)])
             .order(worked_in: :asc)
             .to_a
      output_calendar(data, base_date, 7)
    end

    # 指定した期間内に日報を提出したユーザーの配列を返す
    # @param [Date] start_on
    # @param [Date] end_on
    # @return [Array] users
    def submitted_users(start_on, end_on)
      user_ids = where(worked_in: [start_on..end_on])
                 .select(:user_id)
                 .uniq
                 .pluck(:user_id)
      User.available.where(id: user_ids)
    end

    # 該当のユーザーが指定期間内で日報未提出の日付を返す
    # @param [Integer] user_id
    # @param [Date] start_on
    # @param [Date] end_on
    # @return [Array]
    def unsubmitted_dates(user_id, start_on: nil, end_on: nil)
      result = []
      user = User.find(user_id)
      return result if user.began_on.nil?

      # ユーザーの集計開始日より前のデータは無視する
      start_on = if start_on.present?
                   [start_on, user.began_on].max
                 else
                   user.began_on
                 end
      end_on ||= Time.zone.now.to_date
      reports = where(user_id: user_id, worked_in: start_on..end_on).pluck(:worked_in)
      (start_on..end_on).each do |date|
        next if date.sunday? || date.saturday? || date.holiday?(:jp)

        result << date unless reports.any? { |worked_in| worked_in === date }
      end
      result
    end

    private

    # start_onの日から数えてdays日数分のReportのデータをカレンダー形式で返す
    # @param [Array] data
    # @param [Date] start_on
    # @param [Integer] days
    # @return [Array]
    def output_calendar(data, start_on, days)
      calendar = []
      days.times do |i|
        d = start_on + i
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
