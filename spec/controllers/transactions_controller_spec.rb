require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:widget) { create(:widget) }
    let(:transaction_processor) { instance_double(TransactionProcessor) }
    let(:transaction_result) { instance_double('TransactionResult', success?: success, error_message: error_message) }

    before do
      sign_in user
      allow(TransactionProcessor).to receive(:new).with(user, widget.id.to_s).and_return(transaction_processor)
      allow(transaction_processor).to receive(:process).and_return(transaction_result)
    end

    context 'when the transaction is successful' do
      let(:success) { true }
      let(:error_message) { nil }

      it 'sets a success flash message and redirects to widgets_path' do
        post :create, params: { widget_id: widget.id }

        expect(flash[:notice]).to eq('Purchase successful!')
        expect(response).to redirect_to(widgets_path)
      end
    end

    context 'when the transaction fails' do
      let(:success) { false }
      let(:error_message) { 'Insufficient funds' }

      it 'sets an alert flash message and redirects to widgets_path' do
        post :create, params: { widget_id: widget.id }

        expect(flash[:alert]).to eq('Insufficient funds')
        expect(response).to redirect_to(widgets_path)
      end
    end
  end
end
