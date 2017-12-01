class Bill < ApplicationRecord
  belongs_to :estimate

  validates :serial_no, presence: true
  validates :subject, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :filename, presence: true

  # 請求金額(税込)
  # @return [Integer]
  def tax_included_amount
    (BigDecimal(self.amount) * (1.0 + AppSettings.consumption_tax_rate)).floor
  end
end
