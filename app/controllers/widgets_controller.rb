class WidgetsController < ApplicationController
  before_action :set_widget, only: %i[show edit update destroy]

  def index
    widgets = WidgetService.new(current_user)
    @available_widgets = widgets.available_for_sale
    @my_widgets = widgets.owned_widgets
    @bought_widgets = widgets.bought_widgets
  end

  def new
    @widget = Widget.new
  end

  def create
    @widget = WidgetService.new(current_user).create_widget(widget_params)

    if @widget.persisted?
      flash[:notice] = 'Widget created successfully'
      redirect_to widgets_path
    else
      flash[:alert] = @widget.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    if @widget.update(update_widget_params)
      flash[:notice] = 'Widget edited successfully'
      redirect_to widgets_path
    else
      flash[:alert] = @widget.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    WidgetService.new(current_user).delete_widget(@widget)
    flash[:notice] = 'Widget deleted successfully'
    redirect_to widgets_path
  end

  private

  def set_widget
    @widget = Widget.find(params[:id])
  end

  def widget_params
    params.require(:widget).permit(:description, :price).merge(status: 'available')
  end

  def update_widget_params
    params.require(:widget).permit(:description, :price)
  end
end
