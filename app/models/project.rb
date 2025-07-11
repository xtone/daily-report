class Project < ApplicationRecord
  enum :category, { undefined: 0, client_shot: 1, client_maintenance: 2, internal: 3, general_affairs: 4, other: 5 }

  has_many :operations
  has_many :user_projects, dependent: :destroy
  has_many :users, through: :user_projects
  has_many :estimates
  has_many :bills, through: :estimates

  validates :code,
            allow_blank: true,
            numericality: { greater_than_or_equal_to: 0 },
            uniqueness: true

  validates :name,
            presence: true,
            sjis_convertible: true

  validates :name_reading,
            presence: true,
            format: { with: /\A[\p{hiragana}ー]+\Z/ },
            sjis_convertible: true

  scope :available, -> { where(hidden: false) }

  scope :order_by_reading, -> { order(name_reading: :asc) }

  class << self
    # 該当のユーザーが関与しているかの情報を含むリストを取得
    # @param [Integer] user_id
    # @return [Array]
    def find_in_user(user_id)
      user_pids = UserProject.where(user_id: user_id).pluck(:project_id)
      list = []
      available.order(name_reading: :asc).each do |project|
        list << {
          id: project.id,
          name: project.name,
          name_reading: project.name_reading,
          code: project.code,
          related: user_pids.include?(project.id)
        }
      end
      list
    end

    # 次に割り当てられるプロジェクトコード
    # 頭2桁が年の下2桁、続く3桁が年内のプロジェクトの通し番号
    # @return [Integer]
    def next_expected_code(at = Time.zone.now)
      [(at.year % 100) * 1000, maximum(:code)].max + 1
    end
  end

  # プロジェクトに(1度でも)関わったユーザーを取得
  # @return [ActiveRecord::Relation]
  def members
    @members ||= User.includes(reports: :operations)
                     .references(:operations)
                     .where(operations: { project_id: id })
  end

  def displayed?
    !hidden
  end

  # 表示ステータス
  # @return [String]
  def display_status
    hidden ? I18n.t('project.display_status.hidden') : I18n.t('project.display_status.display')
  end
end
