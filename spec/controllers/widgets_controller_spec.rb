require 'rails_helper'

RSpec.describe WidgetsController, type: :controller do
  let(:user) { create(:user) }
  let!(:widget) { create(:widget, seller: user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'assigns @available_widgets, @my_widgets, and @bought_widgets' do
      widget_service = instance_double('WidgetService')
      allow(WidgetService).to receive(:new).with(user).and_return(widget_service)
      allow(widget_service).to receive(:available_for_sale).and_return([widget])
      allow(widget_service).to receive(:owned_widgets).and_return([widget])
      allow(widget_service).to receive(:bought_widgets).and_return([])

      get :index

      expect(assigns(:available_widgets)).to eq([widget])
      expect(assigns(:my_widgets)).to eq([widget])
      expect(assigns(:bought_widgets)).to eq([])
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'assigns a new widget' do
      get :new
      expect(assigns(:widget)).to be_a_new(Widget)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    let(:widget_params) { { description: 'New Widget', price: '100.0' } }

    context 'when the widget is successfully created' do
      it 'redirects to widgets_path with a success message' do
        widget_service = instance_double('WidgetService')
        created_widget = build_stubbed(:widget)
        allow(created_widget).to receive(:persisted?).and_return(true)

        allow(WidgetService).to receive(:new).with(user).and_return(widget_service)
        allow(widget_service).to receive(:create_widget).with(
          ActionController::Parameters.new(widget_params).permit(:description, :price).merge(status: 'available')
        ).and_return(created_widget)

        post :create, params: { widget: widget_params }

        expect(flash[:notice]).to eq('Widget created successfully')
        expect(response).to redirect_to(widgets_path)
      end
    end


    context 'when the widget fails to be created' do
      it 'renders the new template with an error message' do
        widget_service = instance_double('WidgetService')
        invalid_widget = build_stubbed(:widget)
        allow(invalid_widget).to receive(:persisted?).and_return(false)
        allow(invalid_widget).to receive_message_chain(:errors, :full_messages).and_return(['Error creating widget'])

        allow(WidgetService).to receive(:new).with(user).and_return(widget_service)
        allow(widget_service).to receive(:create_widget).and_return(invalid_widget)

        post :create, params: { widget: widget_params }

        expect(flash[:alert]).to eq('Error creating widget')
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    let(:update_params) { { description: 'Updated Widget', price: 200.0 } }

    context 'when the widget is successfully updated' do
      it 'redirects to widgets_path with a success message' do
        patch :update, params: { id: widget.id, widget: update_params }

        expect(flash[:notice]).to eq('Widget edited successfully')
        expect(response).to redirect_to(widgets_path)
      end
    end

    context 'when the widget fails to update' do
      it 'renders the edit template with an error message' do
        allow_any_instance_of(Widget).to receive(:update).and_return(false)
        allow_any_instance_of(Widget).to receive_message_chain(:errors, :full_messages).and_return(['Error updating widget'])

        patch :update, params: { id: widget.id, widget: update_params }

        expect(flash[:alert]).to eq('Error updating widget')
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'redirects to widgets_path with a success message' do
      widget_service = instance_double('WidgetService')
      allow(WidgetService).to receive(:new).with(user).and_return(widget_service)
      allow(widget_service).to receive(:delete_widget).with(widget).and_return(true)

      delete :destroy, params: { id: widget.id }

      expect(flash[:notice]).to eq('Widget deleted successfully')
      expect(response).to redirect_to(widgets_path)
    end
  end
end
