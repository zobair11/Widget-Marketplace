class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :balance, dependent: :destroy
  has_many :widgets, foreign_key: 'seller_id', dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :transactions_as_seller, class_name: 'Transaction', foreign_key: 'seller_id', dependent: :destroy
  has_many :transactions_as_buyer, class_name: 'Transaction', foreign_key: 'buyer_id', dependent: :destroy

  validates :first_name, :last_name, presence: true, length: { maximum: 50 }

  after_create :initialize_balance

  enum role: { general_user: 0, admin: 1 }

  def current_balance
    balance.balance
  end

  private

  def initialize_balance
    BalanceInitializer.new(self).call
  end
end
