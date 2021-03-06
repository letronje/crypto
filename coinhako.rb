require_relative "transaction"

class CoinhakoTransaction < Hashie::Dash
  property :pair, required: true
  property :side, required: true
  property :type, required: true
  property :average_price, required: true
  property :price, required: true
  property :amount, required: true
  property :executed, required: true
  property :fee, required: true
  property :total, required: true
  property :status, required: true
  property :timestamp, required: true

  def self.from_csv_row(row)
    self.new([
      :pair,
      :side,
      :type,
      :average_price,
      :price,
      :amount,
      :executed,
      :fee,
      :total,
      :status,
      :timestamp,
    ].zip(row.map(&:to_s)).to_h)
  end

  def self.from_csv_file(file)
    return [] if file.nil?

    rows = CSV.new(File.read(file)).read

    rows.map.with_index do |r, index|
      next if index.zero?
      from_csv_row(r).to_transaction
    end.compact
  end

  def completed?
    status == "Completed"
  end

  def to_transaction
    # TODO: what are the other possible values for "status" ?
    unless completed?
      puts "Found an incomplete transaction: #{self.inspect}"
      return nil
    end

    currency1, currency2 = pair.split("/")

    Transaction.new(
      exchange: EXCHANGE_COINHAKO,
      crypto_currency: currency1.downcase.to_sym,
      fiat_currency: currency2.downcase.to_sym,
      type: transaction_type,
      price: BigDecimal(price, BIG_DEC_SIG_DIGITS),
      source_amount: BigDecimal(amount, BIG_DEC_SIG_DIGITS),
      trade_fee: BigDecimal(fee, BIG_DEC_SIG_DIGITS),
      obtain_amount: BigDecimal(total, BIG_DEC_SIG_DIGITS),
      at: Time.parse(timestamp),
    )
  end

  def transaction_type
    case side
    when "Buy"
      TRANSACTION_TYPE_BUY
    when "Sell"
      TRANSACTION_TYPE_SELL
    else
      raise "oops"
    end
  end
end
