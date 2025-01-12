require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }
  let(:widget) { create(:widget, seller: seller, price: 100.0) }
  let(:transaction) { create(:transaction, seller: seller, buyer: buyer, widget: widget, marketplace_fee: 5.0) }

  describe 'associations' do
    it { should belong_to(:seller).class_name('User') }
    it { should belong_to(:buyer).class_name('User') }
    it { should belong_to(:widget) }
  end

  describe 'validations' do
    it { should validate_presence_of(:marketplace_fee) }
    it { should validate_numericality_of(:marketplace_fee).is_greater_than(0) }
  end

  describe '#seller_income' do
    it 'calculates the seller’s income after marketplace fee deduction' do
      expect(transaction.seller_income).to eq(95.0)
    end
  end

  describe '.marketplace_fee' do
    it 'calculates the marketplace fee based on the price' do
      fee = Transaction.marketplace_fee(200.0)
      expect(fee).to eq(10.0)
    end
  end

  describe '.total_platform_fee' do
    it 'calculates the total platform fees for all transactions' do
      create(:transaction, seller: seller, buyer: buyer, widget: widget, marketplace_fee: 5.0)
      create(:transaction, seller: seller, buyer: buyer, widget: widget, marketplace_fee: 10.0)
      expect(Transaction.total_platform_fee).to eq(15.0)
    end
  end
end
