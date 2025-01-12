require 'rails_helper'

RSpec.describe Widget, type: :model do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:widget) { create(:widget, seller: user, price: 100.0, description: 'Test Widget') }

  describe 'associations' do
    it { should belong_to(:seller).class_name('User') }
    it { should have_one(:sale_transaction).class_name('Transaction') }
  end

  describe 'validations' do
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
    it { should validate_presence_of(:description) }
  end

  describe 'scopes' do
    let!(:available_widget) { create(:widget, seller: other_user, status: 'available') }
    let!(:sold_widget) { create(:widget, seller: other_user, status: 'sold') }
    let!(:user_owned_widget) { create(:widget, seller: user, status: 'available') }

    describe 'available_for_sale' do
      it 'returns widgets available for sale excluding the user’s widgets and sold widgets' do
        expect(Widget.available_for_sale(user)).to include(available_widget)
        expect(Widget.available_for_sale(user)).not_to include(sold_widget, user_owned_widget)
      end
    end

    describe 'owned_by_user' do
      it 'returns widgets owned by the user excluding sold widgets' do
        expect(Widget.owned_by_user(user)).to include(user_owned_widget)
        expect(Widget.owned_by_user(user)).not_to include(sold_widget, available_widget)
      end
    end

    describe 'bought_by_user' do
      let!(:transaction) { create(:transaction, buyer: user, seller: other_user, widget: available_widget) }

      it 'returns widgets bought by the user' do
        expect(Widget.bought_by_user(user)).to include(available_widget)
      end
    end
  end

  describe '#mark_as_sold!' do
    it 'updates the widget status to sold' do
      widget.mark_as_sold!
      expect(widget.reload.status).to eq('sold')
    end
  end
end
