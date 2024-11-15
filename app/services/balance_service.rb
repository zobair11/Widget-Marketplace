class BalanceService
  def initialize(balance)
    @balance = balance
  end

  def sufficient_for?(amount)
    @balance.sufficient?(amount)
  end

  def adjust_balance(amount)
    @balance.update!(balance: @balance.current + amount)
  end
end
