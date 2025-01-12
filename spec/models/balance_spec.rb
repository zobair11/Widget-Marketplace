require 'rails_helper'

RSpec.describe Balance, type: :model do
  let(:user) { create(:user) }
  let(:balance) { create(:balance, user: user, balance: 100.0) }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:balance) }
    it { should validate_numericality_of(:balance).is_greater_than_or_equal_to(0) }
  end

  describe '#current' do
    it 'returns the current balance' do
      expect(balance.current).to eq(100.0)
    end
  end

  describe '#sufficient?' do
    context 'when the balance is sufficient' do
      it 'returns true' do
        expect(balance.sufficient?(50.0)).to be_truthy
      end
    end

    context 'when the balance is insufficient' do
      it 'returns false' do
        expect(balance.sufficient?(150.0)).to be_falsey
      end
    end
  end
end
