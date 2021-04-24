require "csv"
require "time"
require "json"
require "bigdecimal"
require "bigdecimal/util"

require "rubygems"
require "bundler/setup"
Bundler.require(:default)

require "active_support/all"

require_relative "constants"
require_relative "coinhako"
require_relative "binance_sg"
require_relative "transactions"

def per(a, b, n = 3)
  p = ((a * 100.0) / b.to_f).round(n)
  "#{p}%"
end

all_transactions = CoinhakoTransaction.from_csv_file(ARGV[0]) + BinanceSGTransaction.from_json_file(ARGV[1])

all_transactions.group_by { |t| [t.crypto_currency, t.fiat_currency] }.each do |pair, transactions|
  cc, fc = pair

  cc = cc.to_s.upcase
  fc = fc.to_s.upcase

  puts
  print("-" * 25)
  print("#{}---------------- #{cc} / #{fc} ------------------")
  puts("-" * 25)
  puts

  buys = transactions.select(&:buy?)
  buys_by_exchange = buys.group_by(&:exchange)

  total_obtained = BigDecimal("0")
  total_spent = BigDecimal("0")
  total_trade_fee = BigDecimal("0")

  table = Terminal::Table.new do |t|
    t.title = "Buys"
    t.headings = ["Exchange", cc, fc, "Fee", "# Transactions"]
    t.style = { :border => Terminal::Table::UnicodeBorder.new() }

    EXCHANGES.each do |e|
      ebuys = buys_by_exchange[e] || []
      next if ebuys.blank?
      crypto_obtained = ebuys.sum(&:obtain_amount); total_obtained += crypto_obtained
      fiat_spent = ebuys.sum(&:source_amount); total_spent += fiat_spent
      trade_fee = ebuys.sum(&:trade_fee); total_trade_fee += trade_fee
      t.add_row [
        e.to_s.titleize,
        crypto_obtained,
        fiat_spent,
        "#{trade_fee} ( #{per(trade_fee, fiat_spent)} )",
        ebuys.size,
      ]
    end

    if t.rows.size > 1
      t.add_separator border_type: :double
      t.add_row [
                  "TOTAL",
                  total_obtained,
                  total_spent,
                  "#{total_trade_fee} ( #{per(total_trade_fee, total_spent)} )",
                  buys.size,
                ]
    end
  end

  avg_buy_price = total_spent / total_obtained

  puts table if buys.present?

  puts("\nAverage Buy price: #{avg_buy_price}\n\n")

  table = Terminal::Table.new do |t|
    t.title = "Notable Buys"
    t.headings = ["Type", "Time", "Exchange", fc, "Rate", cc]
    t.style = { :border => Terminal::Table::UnicodeBorder.new() }

    b = buys.max_by(&:price)

    t.add_row [
      "Lowest Rate",
      b.at.to_formatted_s(:rfc822),
      b.exchange.to_s.titleize,
      b.source_amount,
      b.price,
      b.obtain_amount,
    ]

    b = buys.min_by(&:price)
    t.add_row [
      "Highest Rate",
      b.at.to_formatted_s(:rfc822),
      b.exchange.to_s.titleize,
      b.source_amount,
      b.price,
      b.obtain_amount,
    ]

    b = buys.min_by(&:at)
    t.add_row [
      "Most Recent",
      b.at.to_formatted_s(:rfc822),
      b.exchange.to_s.titleize,
      b.source_amount,
      b.price,
      b.obtain_amount,
    ]

    b = buys.max_by(&:obtain_amount)
    t.add_row [
      "Most Crypto Obtained",
      b.at.to_formatted_s(:rfc822),
      b.exchange.to_s.titleize,
      b.source_amount,
      b.price,
      b.obtain_amount,
    ]

    b = buys.min_by(&:obtain_amount)
    t.add_row [
      "Least Crypto Obtained",
      b.at.to_formatted_s(:rfc822),
      b.exchange.to_s.titleize,
      b.source_amount,
      b.price,
      b.obtain_amount,
    ]
  end

  puts table

  sells = transactions.select(&:sell?)
  sells_by_exchange = sells.group_by(&:exchange)

  total_obtained = BigDecimal("0")
  total_spent = BigDecimal("0")
  total_trade_fee = BigDecimal("0")

  table = Terminal::Table.new do |t|
    t.title = "Sells"
    t.headings = ["Exchange", cc, fc, "Fee", "# Transactions"]
    t.style = { :border => Terminal::Table::UnicodeBorder.new() }

    EXCHANGES.each do |e|
      esells = sells_by_exchange[e] || []
      next if esells.blank?
      fiat_obtained = esells.sum(&:obtain_amount); total_obtained += fiat_obtained
      crypto_spent = esells.sum(&:source_amount); total_spent += crypto_spent
      trade_fee = esells.sum(&:trade_fee); total_trade_fee += trade_fee
      t.add_row [
        e.to_s.titleize,
        crypto_spent,
        fiat_obtained,
        trade_fee,
        esells.size,
      ]
    end

    if t.rows.size > 1
      t.add_separator border_type: :double
      t.add_row [
                  "TOTAL",
                  total_spent,
                  total_obtained,
                  total_trade_fee,
                  sells.size,
                ]
    end
  end

  avg_sell_price = total_obtained / total_spent

  puts table if sells.present?

  if sells.present?
    puts("\nAverage Sell price: #{avg_sell_price}\n\n")

    table = Terminal::Table.new do |t|
      t.title = "Notable Sells"
      t.headings = ["Type", "Time", "Exchange", fc, "Rate", cc]
      t.style = { :border => Terminal::Table::UnicodeBorder.new() }

      b = sells.max_by(&:price)

      t.add_row [
                  "Lowest Rate",
                  b.at.to_formatted_s(:rfc822),
                  b.exchange.to_s.titleize,
                  b.source_amount,
                  b.price,
                  b.obtain_amount,
                ]

      b = sells.min_by(&:price)
      t.add_row [
                  "Highest Rate",
                  b.at.to_formatted_s(:rfc822),
                  b.exchange.to_s.titleize,
                  b.source_amount,
                  b.price,
                  b.obtain_amount,
                ]

      b = sells.min_by(&:at)
      t.add_row [
                  "Most Recent",
                  b.at.to_formatted_s(:rfc822),
                  b.exchange.to_s.titleize,
                  b.source_amount,
                  b.price,
                  b.obtain_amount,
                ]

      b = sells.max_by(&:obtain_amount)
      t.add_row [
                  "Most Fiat Obtained",
                  b.at.to_formatted_s(:rfc822),
                  b.exchange.to_s.titleize,
                  b.source_amount,
                  b.price,
                  b.obtain_amount,
                ]

      b = sells.min_by(&:obtain_amount)
      t.add_row [
                  "Least Fiat Obtained",
                  b.at.to_formatted_s(:rfc822),
                  b.exchange.to_s.titleize,
                  b.source_amount,
                  b.price,
                  b.obtain_amount,
                ]
    end

    puts table
  end

  total_bought = buys.sum(&:obtain_amount)
  total_sold = sells.sum(&:source_amount)

  puts "\nTotal #{cc} owned: #{total_bought - total_sold} ( Bought: #{total_bought}, Sold: #{total_sold})"
end
