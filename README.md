# Usage

Ensure you have ruby installed. Known to work with versions 2.7, 3.0 on Macbook Air M1 running Big Sur. YMMV
```
ruby -v 
```

Incase you don't have bundler ...
```
gem install bundler
```

Install dependencies
```
bundle install
```

Run
```
ruby crypto.rb coinhako.csv binance.json 
```

## Coinhako

* Login to coinhako.com
* Goto "Trade History" page ( https://www.coinhako.com/wallet/history/trade ) 
* Download CSV and save as `coinhako.csv`

## Binance SG

* Login to binance.sg
* Goto "History -> Buy/Sell" ( https://www.binance.sg/en/usercenter/history/buysell )
* Open dev tools (Cmd + Shift + I)
* Copy the response of the API call https://www.binance.sg/gateway-api/v1/private/ocbs/get-user-payment-history
* Save it as `binance.json`

## Gemini

* WIP