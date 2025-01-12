class PaymentProcessor
  def initialize(user, params)
    @user = user
    @card_number = params[:card_number]
    @expiry_month = params[:expiry_month]
    @expiry_year = params[:expiry_year]
    @cvc = params[:cvc]
    @amount = params[:amount].to_f
  end

  def process
    return Result.failure('Invalid deposit amount') if @amount <= 0

    token = create_stripe_token
    charge_stripe(token)

    create_payment_record

    Result.success
  rescue Stripe::CardError => e
    Result.failure(e.message)
  rescue StandardError
    Result.failure('Something went wrong. Please try again.')
  end

  private

  def create_stripe_token
    Stripe::Token.create({
                           card: {
                             number: @card_number,
                             exp_month: @expiry_month,
                             exp_year: @expiry_year,
                             cvc: @cvc
                           }
                         })
  end

  def charge_stripe(token)
    Stripe::Charge.create({
                            amount: (@amount * 100).to_i,
                            currency: 'usd',
                            source: token.id,
                            description: "Deposit by #{@user.email}"
                          })
  end

  def create_payment_record
    Payment.create!(
      user: @user,
      amount: @amount
    )
  end
end
