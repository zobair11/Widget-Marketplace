class Transaction < ApplicationRecord
  belongs_to :seller, class_name: 'User'
  belongs_to :buyer, class_name: 'User'
  belongs_to :widget

  validates :marketplace_fee, presence: true

  def seller_income
    widget.price - marketplace_fee
  end

  def self.marketplace_fee(price)
    price * 0.05
  end

  def self.total_platform_fee
    sum(:marketplace_fee)
  end
end
