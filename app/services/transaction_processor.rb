class TransactionProcessor
  def initialize(user, widget_id)
    @user = user
    @widget = Widget.find(widget_id)
    @balance_service = BalanceService.new(user.balance)
  end

  def process
    return Result.failure('Insufficient balance') unless @balance_service.sufficient_for?(@widget.price)

    ActiveRecord::Base.transaction do
      transaction = create_transaction
      adjust_balances(transaction)
      @widget.mark_as_sold!
    end

    Result.success
  rescue ActiveRecord::RecordInvalid => e
    Result.failure(e.message)
  rescue => e
    Result.failure('Something went wrong. Please try again.')
  end

  private

  def create_transaction
    Transaction.create!(
      seller: @widget.seller,
      buyer: @user,
      widget: @widget,
      marketplace_fee: Transaction.marketplace_fee(@widget.price)
    )
  end

  def adjust_balances(transaction)
    @balance_service.adjust_balance(-@widget.price)

    BalanceService.new(@widget.seller.balance).adjust_balance(transaction.seller_income)
  end
end
