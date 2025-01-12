require 'rails_helper'

RSpec.describe BalanceService do
  let(:balance) { instance_double('Balance', current: 100.0) }
  let(:balance_service) { described_class.new(balance) }

  describe '#sufficient_for?' do
    context 'when the balance is sufficient' do
      it 'returns true' do
        allow(balance).to receive(:sufficient?).with(50.0).and_return(true)

        result = balance_service.sufficient_for?(50.0)
        expect(result).to be true
      end
    end

    context 'when the balance is insufficient' do
      it 'returns false' do
        allow(balance).to receive(:sufficient?).with(150.0).and_return(false)

        result = balance_service.sufficient_for?(150.0)
        expect(result).to be false
      end
    end
  end

  describe '#adjust_balance' do
    context 'when adjusting the balance' do
      it 'updates the balance with the correct amount' do
        new_balance = balance.current + 50.0
        expect(balance).to receive(:update!).with(balance: new_balance)

        balance_service.adjust_balance(50.0)
      end

      it 'can decrease the balance' do
        new_balance = balance.current - 30.0
        expect(balance).to receive(:update!).with(balance: new_balance)

        balance_service.adjust_balance(-30.0)
      end
    end
  end
end
