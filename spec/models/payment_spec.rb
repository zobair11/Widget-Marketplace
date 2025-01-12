require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe 'callbacks' do
    describe 'after_create :process_payment' do
      it 'increments the user’s balance by the payment amount' do
        create(:payment, user: user, amount: 50.0)
        expect(user.balance.reload.balance.to_f).to eq(50.0)
      end
    end
  end
end
