class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_user_context, if: :user_signed_in?
  before_action :authenticate_user!

  protected

  def set_user_context
    @current_user_balance = current_user.current_balance
    @total_platform_fee = Transaction.total_platform_fee if current_user.admin?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  end
end
