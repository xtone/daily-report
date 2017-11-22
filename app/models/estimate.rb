class EstimateValidator < ActiveModel::Validator
  def validate(record)
    if record.director_manday + record.engineer_manday + record.designer_manday + record.other_manday <= 0.0
      record.errors.add(:base, '工数の合計がゼロです。')
    end
  end
end

class Estimate < ApplicationRecord
  belongs_to :project

  validates :subject, presence: true
  validates :serial_no, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :filename, presence: true

  validates_with EstimateValidator

  # 過去に全く同じ工数・原価設定があるか調べる
  # @return [Boolean]
  def deja_vu?
    self.class.where(
      director_manday: self.director_manday,
      engineer_manday: self.engineer_manday,
      designer_manday: self.designer_manday,
      cost: self.cost
    ).exists?
  end

  # 見積もり日付が半年以上前か？
  # @param [Date] on 判定基準となる日付
  # @return [Boolean]
  def too_old?(on = Time.current.to_date)
    on - self.estimated_on > 180
  end
end
