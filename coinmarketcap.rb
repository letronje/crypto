class CoinMarketCap
  def initialize(key)
    @cache = {}
    @api_key = key
  end

  def quotes
    fiat = FIAT_CURRENCY.to_s.upcase
    symbols = CRYPTO_SYMBOLS.map { |s| s.to_s.upcase }.join(",")
    url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?convert=SGD&symbol=#{symbols}"
    request_headers = {
      "X-CMC_PRO_API_KEY" => @api_key,
    }
    resp = Faraday.get(url, nil, request_headers)
    JSON.parse(resp.body)["data"].map do |crypto, data|
      [data["symbol"].downcase.to_sym, data["quote"][fiat]["price"]]
    end.to_h
  end

  def price(crypto)
    @cache = quotes if @cache.empty?
    @cache[crypto]
  end
end
