class Project < ApplicationRecord
  has_many :projects

  validates :code,
    allow_blank: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :name,
    presence: true

  validates :name_reading,
    presence: true,
    format: { with: /\A[\p{hiragana}ー]+\Z/ }

  class << self
    # 次に割り当てられるプロジェクトコード
    # 頭2桁が年の下2桁、続く3桁が年内のプロジェクトの通し番号
    # @return [Integer]
    def next_expected_code(at = Time.zone.now)
      this_year_projects = where(created_at: (at.beginning_of_year)..(at.end_of_year)).count
      (at.year % 100) * 1000 + this_year_projects + 1
    end
  end

  # 表示ステータス
  # @return [String]
  def display_status
    self.hidden ? I18n.t('project.display_status.hidden') : I18n.t('project.display_status.display')
  end
end
