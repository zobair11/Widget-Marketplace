class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    result = PaymentProcessor.new(current_user, payment_params).process

    if result.success?
      flash[:notice] = 'Deposit successful!'
      redirect_to root_path
    else
      flash[:alert] = result.error_message
      redirect_to new_payment_path
    end
  end

  private

  def payment_params
    params.permit(:card_number, :expiry_month, :expiry_year, :cvc, :amount)
  end
end
