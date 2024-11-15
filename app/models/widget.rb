class Widget < ApplicationRecord
  belongs_to :seller, class_name: 'User'
  has_one :sale_transaction, class_name: 'Transaction'

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true

  scope :available_for_sale, ->(user) { where.not(seller: user).where.not(status: 'sold') }
  scope :owned_by_user, ->(user) { user.widgets.where.not(status: 'sold') }
  scope :bought_by_user, ->(user) { joins(:sale_transaction).where(sale_transaction: { buyer_id: user.id }) }

  def mark_as_sold!
    update!(status: 'sold')
  end
end
