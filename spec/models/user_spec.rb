require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should have_one(:balance).dependent(:destroy) }
    it { should have_many(:widgets).with_foreign_key('seller_id').dependent(:destroy) }
    it { should have_many(:payments).dependent(:destroy) }
    it {
      should have_many(:transactions_as_seller)
        .class_name('Transaction').with_foreign_key('seller_id').dependent(:destroy)
    }
    it {
      should have_many(:transactions_as_buyer)
        .class_name('Transaction').with_foreign_key('buyer_id').dependent(:destroy)
    }
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_length_of(:first_name).is_at_most(50) }
    it { should validate_length_of(:last_name).is_at_most(50) }
  end

  describe 'callbacks' do
    describe 'after_create :initialize_balance' do
      it 'initializes a balance for the user' do
        user = create(:user)
        expect(user.balance).not_to be_nil
        expect(user.balance.balance).to eq(0.0)
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(general_user: 0, admin: 1) }
  end

  describe '#current_balance' do
    it 'returns the current balance of the user' do
      user.balance.update!(balance: 150.0)
      expect(user.current_balance).to eq(150.0)
    end
  end
end
