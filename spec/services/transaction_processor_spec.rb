require 'rails_helper'

RSpec.describe TransactionProcessor do
  let(:user_balance) { 100 }
  let(:seller_balance) { 50 }
  let(:widget_price) { 80 }
  let(:user) { create(:user) }
  let(:seller) { create(:user) }
  before do
    user.balance.update!(balance: user_balance)
    seller.balance.update!(balance: seller_balance)
  end
  let(:widget) { create(:widget, price: widget_price, seller: seller) }
  let(:transaction_processor) { described_class.new(user, widget.id) }

  describe '#process' do
    context 'when the user has insufficient balance' do
      let(:user_balance) { 50 }

      it 'returns a failure result with an appropriate message' do
        result = transaction_processor.process
        expect(result).to be_failure
        expect(result.error_message).to eq('Insufficient balance')
      end

      it 'does not create a transaction' do
        expect { transaction_processor.process }.not_to(change { Transaction.count })
      end
    end

    context 'when the transaction is successful' do
      it 'creates a transaction' do
        expect { transaction_processor.process }.to change { Transaction.count }.by(1)
        transaction = Transaction.last
        expect(transaction.buyer).to eq(user)
        expect(transaction.seller).to eq(seller)
        expect(transaction.widget).to eq(widget)
        expect(transaction.marketplace_fee).to eq(Transaction.marketplace_fee(widget.price))
      end
      it 'adjusts the user and seller balances' do
        allow(Widget).to receive(:find).with(widget.id).and_return(widget)
        expect { transaction_processor.process }.to change { user.balance.reload.balance }
          .by(-widget_price)
          .and change { seller.balance.reload.balance }
          .by(widget.price - Transaction.marketplace_fee(widget.price))
      end

      it 'marks the widget as sold' do
        allow(Widget).to receive(:find).with(widget.id).and_return(widget)
        expect(widget).to receive(:mark_as_sold!)
        transaction_processor.process
      end

      it 'returns a successful result' do
        result = transaction_processor.process
        expect(result).to be_success
      end
    end

    context 'when a validation error occurs' do
      before do
        allow(Transaction).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Transaction.new))
      end

      it 'returns a failure result with the validation error message' do
        result = transaction_processor.process
        expect(result).to be_failure
        expect(result.error_message).to include('Validation failed')
      end

      it 'does not mark the widget as sold' do
        expect(widget).not_to receive(:mark_as_sold!)
        begin
          transaction_processor.process
        rescue StandardError
          nil
        end
      end

      it 'does not adjust balances' do
        expect_any_instance_of(BalanceService).not_to receive(:adjust_balance)
        begin
          transaction_processor.process
        rescue StandardError
          nil
        end
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(Widget).to receive(:find).with(widget.id).and_return(widget)
        allow(widget).to receive(:mark_as_sold!).and_raise(StandardError.new('Unexpected error'))
      end

      it 'returns a failure result with a generic error message' do
        result = transaction_processor.process
        expect(result).to be_failure
        expect(result.error_message).to eq('Something went wrong. Please try again.')
      end
    end
  end
end
