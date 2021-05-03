require_relative "transaction"

class GeminiTransaction < Hashie::Dash
  include Hashie::Extensions::IgnoreUndeclared
  include Hashie::Extensions::IndifferentAccess

  property :price, required: true
  property :amount, required: true
  property :timestamp, required: true
  property :type, required: true
  property :fee_currency, required: true
  property :fee_amount, required: true
  property :symbol, required: true

  def self.from_api(key, secret)
    return [] if key.blank? || secret.blank?

    path = "/v1/mytrades"
    url = "https://api.gemini.com#{path}"

    payload = {
      "nonce": Time.now.to_i.to_s,
      "request": path,
      "limit_trades": 500,
    }.to_json

    b64_payload = Base64.strict_encode64(payload)

    signature = OpenSSL::HMAC.hexdigest("SHA384", secret, b64_payload)

    request_headers = {
      'Content-Type': "text/plain",
      'Content-Length': "0",
      'X-GEMINI-APIKEY': key,
      'X-GEMINI-PAYLOAD': b64_payload,
      'X-GEMINI-SIGNATURE': signature,
      'Cache-Control': "no-cache",
    }

    resp = Faraday.post(url, nil, request_headers)
    JSON.parse(resp.body).map { |t|
      GeminiTransaction.new(t).to_transaction
    }
  end

  def to_transaction
    currency1 = symbol.gsub("SGD", "").gsub("USD", "")
    currency2 = symbol.gsub(currency1, "")

    Transaction.new(
      exchange: EXCHANGE_GEMINI,
      crypto_currency: currency1.downcase.to_sym,
      fiat_currency: currency2.downcase.to_sym,
      type: transaction_type,
      price: BigDecimal(price, BIG_DEC_SIG_DIGITS),
      source_amount: (BigDecimal(price, BIG_DEC_SIG_DIGITS) * BigDecimal(amount, BIG_DEC_SIG_DIGITS)).round(2).to_f,
      trade_fee: BigDecimal(fee_amount, BIG_DEC_SIG_DIGITS),
      obtain_amount: BigDecimal(amount, BIG_DEC_SIG_DIGITS),
      at: Time.at(timestamp.to_i),
    )
  end

  def transaction_type
    case type
    when "Buy"
      TRANSACTION_TYPE_BUY
    else
      raise "oops, unknown gemini transaction type '#{type}'"
    end
  end
end
