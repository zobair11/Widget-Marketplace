require 'rails_helper'

RSpec.describe PaymentProcessor do
  let(:user) { create(:user) }
  let(:params) do
    {
      card_number: '4242424242424242',
      expiry_month: 12,
      expiry_year: 2025,
      cvc: '123',
      amount: amount
    }
  end
  let(:amount) { 100.0 }
  let(:payment_processor) { described_class.new(user, params) }

  describe '#process' do
    let(:stripe_charge) { instance_double(Stripe::Charge) }

    before do
      token_mock = Struct.new(:id).new('tok_123')
      allow(Stripe::Token).to receive(:create).and_return(token_mock)
      allow(Stripe::Charge).to receive(:create).and_return(stripe_charge)
    end

    context 'when the amount is valid' do
      let(:stripe_token) { double('Stripe::Token', id: 'tok_123') }
      let(:stripe_charge) { double('Stripe::Charge') }

      before do
        allow(Stripe::Token).to receive(:create).and_return(stripe_token)
        allow(Stripe::Charge).to receive(:create).and_return(stripe_charge)
      end

      it 'creates a Stripe token' do
        expect(Stripe::Token).to receive(:create).with(hash_including(
                                                         card: {
                                                           number: '4242424242424242',
                                                           exp_month: 12,
                                                           exp_year: 2025,
                                                           cvc: '123'
                                                         }
                                                       )).and_return(stripe_token)

        payment_processor.process
      end


      it 'charges Stripe with the token' do
        expect(Stripe::Charge).to receive(:create).with(hash_including(
          amount: 10000,
          currency: 'usd',
          source: 'tok_123',
          description: "Deposit by #{user.email}"
        )).and_return(stripe_charge)

        payment_processor.process
      end

      it 'creates a payment record' do
        expect { payment_processor.process }.to change { Payment.count }.by(1)
        payment = Payment.last
        expect(payment.user).to eq(user)
        expect(payment.amount).to eq(100.0)
      end

      it 'returns a successful result' do
        result = payment_processor.process
        expect(result).to be_success
      end
    end

    context 'when the amount is invalid' do
      let(:amount) { 0 }

      it 'does not create a Stripe token or charge' do
        expect(Stripe::Token).not_to receive(:create)
        expect(Stripe::Charge).not_to receive(:create)

        payment_processor.process
      end

      it 'does not create a payment record' do
        expect { payment_processor.process }.not_to(change { Payment.count })
      end

      it 'returns a failure result with an appropriate message' do
        result = payment_processor.process
        expect(result).to be_failure
        expect(result.error_message).to eq('Invalid deposit amount')
      end
    end

    context 'when Stripe raises a card error' do
      before do
        allow(Stripe::Charge).to receive(:create).and_raise(Stripe::CardError.new('Card declined', :charge))
      end

      it 'does not create a payment record' do
        expect { payment_processor.process }.not_to(change { Payment.count })
      end

      it 'returns a failure result with the Stripe error message' do
        result = payment_processor.process
        expect(result).to be_failure
        expect(result.error_message).to eq('Card declined')
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(Stripe::Token).to receive(:create).and_raise(StandardError.new('Unexpected error'))
      end

      it 'does not create a payment record' do
        expect { payment_processor.process }.not_to(change { Payment.count })
      end

      it 'returns a failure result with a generic error message' do
        result = payment_processor.process
        expect(result).to be_failure
        expect(result.error_message).to eq('Something went wrong. Please try again.')
      end
    end
  end
end
