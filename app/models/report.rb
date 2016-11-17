class Report < ApplicationRecord
  belongs_to :user
  has_many :operations
  has_many :projects, through: :operations

  validates :worked_in,
    presence: true
end
