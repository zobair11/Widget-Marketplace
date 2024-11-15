class TransactionsController < ApplicationController
  def create
    result = TransactionProcessor.new(current_user, params[:widget_id]).process

    if result.success?
      flash[:notice] = 'Purchase successful!'
    else
      flash[:alert] = result.error_message
    end

    redirect_to widgets_path
  end
end
