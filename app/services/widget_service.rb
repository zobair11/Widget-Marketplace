class WidgetService
  def initialize(user)
    @user = user
  end

  def available_for_sale
    Widget.available_for_sale(@user)
  end

  def owned_widgets
    Widget.owned_by_user(@user)
  end

  def bought_widgets
    Widget.bought_by_user(@user)
  end

  def create_widget(widget_params)
    @user.widgets.create(widget_params)
  end

  def delete_widget(widget)
    widget.destroy
  end
end
