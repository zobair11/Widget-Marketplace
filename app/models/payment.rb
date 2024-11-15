class Payment < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }

  after_create :process_payment

  private

  def process_payment
    user.balance.increment!(:balance, amount)
  end
end
