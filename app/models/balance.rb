class Balance < ApplicationRecord
  belongs_to :user

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def current
    self.balance
  end

  def sufficient?(amount)
    self.balance >= amount
  end
end
