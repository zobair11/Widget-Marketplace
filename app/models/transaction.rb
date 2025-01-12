class Transaction < ApplicationRecord
  MARKETPLACE_FEE = 0.05

  belongs_to :seller, class_name: 'User'
  belongs_to :buyer, class_name: 'User'
  belongs_to :widget

  validates :marketplace_fee, presence: true, numericality: { greater_than: 0 }

  def seller_income
    widget.price - marketplace_fee
  end

  def self.marketplace_fee(price)
    price * MARKETPLACE_FEE
  end

  def self.total_platform_fee
    sum(:marketplace_fee)
  end
end
