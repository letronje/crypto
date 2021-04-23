require "csv"
require "time"
require "json"
require "rubygems"
require "bundler/setup"
Bundler.require(:default)

require_relative "coinhako"
require_relative "binance_sg"

EXCHANGE_COINHAKO = :coinhako
EXCHANGE_BINANCE_SG = :binance_sg
EXCHANGE_GEMINI = :gemini
TRANSACTION_TYPE_BUY = :buy
TRANSACTION_TYPE_SELL = :sell
TRANSACTION_TYPE_SEND = :send
TRANSACTION_TYPE_RECV = :recv

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
end

# def coinhako_csv_row_to_transaction(r)
#   [
#     :pair,
#     :side,
#     :type,
#     :average_price,
#     :price,
#     :amount,
#     :executed,
#     :fee,
#     :total,
#     :status,
#     :timestamp,
#   ].zip(r).to_h
# end

# def coinhako_transaction_to_transaction(t)
#   return nil if t[:status] != "Completed"
#   currency1, currency2 = t[:pair].split("/")
#   type = t[:side] == "Buy" ? :buy : :sell
#   {
#     exchange: :coinhako,
#     crypto_currency: currency1.downcase.to_sym,
#     fiat_currency: currency2.downcase.to_sym,
#     type: type,
#     price: t[:price].to_f,
#     source_amount: t[:amount].to_f,
#     trade_fee: t[:fee].to_f,
#     obtain_amount: t[:total].to_f,
#     at: Time.parse(t[:timestamp]),
#   }
# end

# def binance_transaction_to_transaction(t)
#   return nil if t["status"] != "4"
#   type = t["payType"] == "1" ? :buy : :sell
#   {
#     exchange: :binance,
#     crypto_currency: t["cryptoCurrency"].downcase.to_sym,
#     fiat_currency: t["fiatCurrency"].downcase.to_sym,
#     type: type,
#     price: t["price"].to_f,
#     source_amount: t["sourceAmount"].to_f,
#     trade_fee: t["tradeFee"].to_f,
#     obtain_amount: t["obtainAmount"].to_f,
#     at: Time.parse(t["createTime"]),
#   }
# end

def transaction_to_str(t)
  "#{t[:obtain_amount]} #{t[:crypto_currency].to_s.upcase} @ #{t[:price]} with #{t[:source_amount]} #{t[:fiat_currency].to_s.upcase} [#{t[:at]}]"
end

transactions = CoinhakoTransaction.from_csv_file(ARGV[0]) + BinanceSGTransaction.from_json_file(ARGV[1])
transactions.sort_by! { |x| -x[:at].to_i }
grouped_transactions = transactions.group_by { |t| [t[:crypto_currency], t[:fiat_currency]] }

grouped_transactions.each do |k, transactions|
  cc, fc = k
  num = 0.0
  denom = 0.0
  min_price = Float::INFINITY
  max_price = -1
  min_price_t = nil
  max_price_t = nil

  transactions.each do |t|
    next if t[:type] != :buy
    price = t[:price]
    source_amount = t[:source_amount]
    num += price * source_amount
    denom += source_amount

    if price < min_price
      min_price = price
      min_price_t = t
    end

    if price > max_price
      max_price = price
      max_price_t = t
    end
  end

  weighted_avg = num / denom
  cc = cc.to_s.upcase
  fc = fc.to_s.upcase
  print("-" * 25)
  print("#{}---------------- #{cc} / #{fc} ------------------")
  puts("-" * 25)
  puts("Average buy price: #{weighted_avg}")
  latest_t = transactions.max_by { |t| t[:at] }
  puts
  puts("Most Recent Buy: #{transaction_to_str(latest_t)}")
  puts("Cheapest Buy: #{transaction_to_str(min_price_t)}")
  puts("Costliest Buy: #{transaction_to_str(max_price_t)}")
  puts
end

ap("hello")
