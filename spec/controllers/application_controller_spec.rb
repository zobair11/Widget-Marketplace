require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'OK'
    end
  end

  let(:user) { create(:user, role: :general_user) }
  let(:admin) { create(:user, role: :admin) }

  describe 'callbacks' do
    context 'when user is signed in' do
      before do
        sign_in user
      end

      it 'sets the user context' do
        allow(Transaction).to receive(:total_platform_fee).and_return(100.0)
        get :index
        expect(assigns(:current_user_balance)).to eq(user.current_balance)
        expect(assigns(:total_platform_fee)).to be_nil
      end
    end

    context 'when admin is signed in' do
      before do
        sign_in admin
      end

      it 'sets the platform fee for admin' do
        allow(Transaction).to receive(:total_platform_fee).and_return(100.0)
        get :index
        expect(assigns(:total_platform_fee)).to eq(100.0)
      end
    end

    context 'when no user is signed in' do
      it 'redirects to the sign-in page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
