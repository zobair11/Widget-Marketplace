class BalanceInitializer
  def initialize(user)
    @user = user
  end

  def call
    @user.create_balance!(balance: 0)
  end
end
