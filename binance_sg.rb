require_relative "transaction"

class BinanceSGTransaction < Hashie::Dash
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

  include Hashie::Extensions::IgnoreUndeclared
  include Hashie::Extensions::IndifferentAccess

  def self.from_json_file(file)
    return [] if file.nil?
    entries = JSON.parse(File.read(file))
    unless entries.is_a?(Array)
      entries = entries["data"]["rows"]["dataList"]
    end
    binance_transactions = entries.map do |e|
      self.new(e).to_transaction
    end.compact
  end

  def completed?
    status == "4"
  end

  def to_transaction
    # TODO: what are the other possible values for "status" ?

    unless completed?
      puts "#{self.inspect}"
      return nil
    end

    Transaction.new(
      exchange: EXCHANGE_BINANCE_SG,
      crypto_currency: cryptoCurrency.downcase.to_sym,
      fiat_currency: fiatCurrency.downcase.to_sym,
      type: transaction_type,
      price: price.to_f,
      source_amount: sourceAmount.to_f,
      trade_fee: tradeFee.to_f,
      obtain_amount: obtainAmount.to_f,
      at: Time.parse(createTime),
    )
  end

  def transaction_type
    case payType
    when "1"
      TRANSACTION_TYPE_BUY
    else
      raise "oops"
    end
  end
end
