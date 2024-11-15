class Balance < ApplicationRecord
  belongs_to :user

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def current
    balance
  end

  def sufficient?(amount)
    balance >= amount
  end
end
