class Transaction < Hashie::Dash
  property :exchange, required: true
  property :crypto_currency, required: true
  property :fiat_currency, required: true
  property :type, required: true
  property :price, required: true
  property :source_amount, required: true
  property :obtain_amount, required: true
  property :trade_fee, required: true
  property :at, required: true

  def crypto_currency_print
    crypto_currency.to_s.upcase
  end

  def fiat_currency_print
    fiat_currency.to_s.upcase
  end

  def pretty_print
    "#{obtain_amount} #{crypto_currency_print} @ #{price} with #{source_amount} #{fiat_currency_print} [#{at}]"
  end

  def buy?
    type == TRANSACTION_TYPE_BUY
  end

  def sell?
    type == TRANSACTION_TYPE_SELL
  end
end
