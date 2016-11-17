class Operation < ApplicationRecord
  belongs_to :report
  belongs_to :project

  validates :workload,
    numericality: { greater_than: 0, less_than_or_equal: 100 }
end
