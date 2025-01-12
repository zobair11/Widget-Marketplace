require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:user) { create(:user) }
  let(:payment_params) do
    {
      card_number: '4242424242424242',
      expiry_month: '12',
      expiry_year: '30',
      cvc: '123',
      amount: '50'
    }
  end

  before do
    sign_in user
  end

  describe 'GET #new' do
    it 'renders the new payment page' do
      get :new
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'when the payment is successful' do
      before do
        allow_any_instance_of(PaymentProcessor).to receive(:process).and_return(Result.success)
      end

      it 'redirects to the root path with a success message' do
        post :create, params: payment_params
        expect(flash[:notice]).to eq('Deposit successful!')
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the payment fails' do
      before do
        allow_any_instance_of(PaymentProcessor).to receive(:process).and_return(Result.failure('Payment failed'))
      end

      it 'redirects to the new payment path with an error message' do
        post :create, params: payment_params
        expect(flash[:alert]).to eq('Payment failed')
        expect(response).to redirect_to(new_payment_path)
      end
    end
  end
end
