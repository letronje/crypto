require_relative "transaction"

class BinanceSGTransaction < Hashie::Dash
  include Hashie::Extensions::IgnoreUndeclared
  include Hashie::Extensions::IndifferentAccess

  property :type, required: true
  property :sourceAmount, required: true
  property :tradeFee, required: true
  property :price, required: true
  property :obtainAmount, required: true
  property :status, required: true
  property :payType, required: true
  property :createTime, required: true
  property :cryptoCurrency, required: true
  property :fiatCurrency, required: true

  def self.from_json_file(file)
    return [] if file.nil?

    entries = JSON.parse(File.read(file))
    entries = entries["data"]["rows"]["dataList"] unless entries.is_a?(Array)
    entries.map do |e|
      bst = new(e)
      bst.to_transaction
    end.compact
  end

  def completed?
    status == "4"
  end

  def to_transaction
    # TODO: what are the other possible values for "status" ?

    unless completed?
      return nil
    end

    Transaction.new(
      exchange: EXCHANGE_BINANCE_SG,
      crypto_currency: cryptoCurrency.downcase.to_sym,
      fiat_currency: fiatCurrency.downcase.to_sym,
      type: transaction_type,
      price: BigDecimal(price, BIG_DEC_SIG_DIGITS),
      source_amount: BigDecimal(sourceAmount, BIG_DEC_SIG_DIGITS),
      trade_fee: BigDecimal(tradeFee, BIG_DEC_SIG_DIGITS),
      obtain_amount: BigDecimal(obtainAmount, BIG_DEC_SIG_DIGITS),
      at: Time.parse(createTime),
    )
  end

  def transaction_type
    case type
    when "1"
      TRANSACTION_TYPE_SELL
    when "0"
      TRANSACTION_TYPE_BUY
    else
      raise "oops"
    end
  end
end
