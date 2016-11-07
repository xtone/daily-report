class Operation < ApplicationRecord
  belongs_to :user
  belongs_to :project, foreign_key: :project_code

  validates :workload,
    numericality: { greater_than: 0, less_than_or_equal: 100 }
end
