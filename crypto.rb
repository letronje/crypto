require 'csv'
require 'time'
require 'json'

def coinhako_csv_row_to_transaction(r)
    [:pair, :side, :type, :average_price, :price, :amount, :executed, :fee, :total, :status, :timestamp].zip(r).to_h
end

def coinhako_transaction_to_transaction(t)
    return nil if t[:status] != "Completed"
    currency1, currency2 = t[:pair].split("/")
    type = t[:side] == "Buy" ? :buy : :sell
    {
        exchange: :coinhako,
        crypto_currency: currency1.downcase.to_sym,
        fiat_currency: currency2.downcase.to_sym,
        type: type,
        price: t[:price].to_f,
        source_amount: t[:amount].to_f,
        trade_fee: t[:fee].to_f,
        obtain_amount: t[:total].to_f,
        at: Time.parse(t[:timestamp])    
    }
end

def binance_transaction_to_transaction(t)
    return nil if t["status"] != "4"
    type = t["payType"] == "1" ? :buy : :sell
    {
        exchange: :binance,
        crypto_currency: t["cryptoCurrency"].downcase.to_sym,
        fiat_currency: t["fiatCurrency"].downcase.to_sym,
        type: type,
        price: t["price"].to_f,
        source_amount: t["sourceAmount"].to_f,
        trade_fee: t["tradeFee"].to_f,
        obtain_amount: t["obtainAmount"].to_f,
        at: Time.parse(t["createTime"])    
    }
end

def coinhako_transactions(file)
    return [] if file.nil? 
    coinhako_rows = CSV.new(File.read(file)).read
    coinhako_transactions = coinhako_rows.map.with_index do |r, index|
        next if index.zero?
        t = coinhako_csv_row_to_transaction(r)
        coinhako_transaction_to_transaction(t)
    end.compact
end

def binance_transactions(file)
    return [] if file.nil? 
    entries = JSON.parse(File.read(file))
    binance_transactions = entries.map do |e|
        binance_transaction_to_transaction(e)
    end.compact
end

transactions = coinhako_transactions(ARGV[0]) + binance_transactions(ARGV[1])

transactions.sort_by!{ |x| -x[:at].to_i }

grouped_transactions = transactions.group_by{ |t| [t[:crypto_currency], t[:fiat_currency]]}

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

    weighted_avg = num/denom

    cc = cc.to_s.upcase
    fc = fc.to_s.upcase

    print "-"*25
    print "#{}---------------- #{cc} / #{fc} ------------------"
    puts "-"*25

    puts "Average buy price: #{weighted_avg}"

    puts "Cheapest Buy: #{min_price_t[:obtain_amount]} #{cc} @ #{min_price_t[:price]} with #{min_price_t[:source_amount]} #{fc} [#{min_price_t[:at]}]"
    puts "Costliest Buy: #{max_price_t[:obtain_amount]} #{cc} @ #{max_price_t[:price]} with #{max_price_t[:source_amount]} #{fc} [#{max_price_t[:at]}]"

    puts 
end





