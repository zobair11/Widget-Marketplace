require 'rails_helper'

RSpec.describe WidgetService do
  let(:user) { create(:user) }
  let(:widget_service) { described_class.new(user) }

  describe '#available_for_sale' do
    it 'returns widgets available for sale' do
      widgets = create_list(:widget, 3, status: 'available', seller: create(:user))
      expect(Widget).to receive(:available_for_sale).with(user).and_return(widgets)

      result = widget_service.available_for_sale
      expect(result).to eq(widgets)
    end
  end

  describe '#owned_widgets' do
    it 'returns widgets owned by the user' do
      widgets = create_list(:widget, 2, seller: user)
      expect(Widget).to receive(:owned_by_user).with(user).and_return(widgets)

      result = widget_service.owned_widgets
      expect(result).to eq(widgets)
    end
  end

  describe '#bought_widgets' do
    it 'returns widgets bought by the user' do
      seller = create(:user)
      widgets = create_list(:widget, 4, seller: seller)
      widgets.each do |widget|
        create(:transaction, buyer: user, seller: seller, widget: widget)
      end

      expect(Widget).to receive(:bought_by_user).with(user).and_return(widgets)

      result = widget_service.bought_widgets
      expect(result).to eq(widgets)
    end
  end

  describe '#create_widget' do
    let(:widget_params) { attributes_for(:widget) }

    it 'creates a new widget for the user' do
      expect(user.widgets).to receive(:create).with(widget_params)
      widget_service.create_widget(widget_params)
    end
  end

  describe '#delete_widget' do
    let(:widget) { create(:widget, seller: user) }

    it 'deletes the specified widget' do
      expect(widget).to receive(:destroy)
      widget_service.delete_widget(widget)
    end
  end
end
