# Features

- Imports crypto transactions from supported exchanges into a single unified list.
- This list can be exported as a csv to be imported into trackers like cointracker.io(more exports coming soon.)
- Prints some basic info like average buy/sell/own price, gains, etc.

# Note 

- Wrote this for me, myself and I. Might work for you if you're lucky.
- Happy path only :) might barf stack traces at you.
- coinmarketcap.com API is used to get latest prices.
- Assumes SGD as fiat currency. PRs are welcome to use other currencies.
- Assumes interest in BAT/DOGE/BTC/ETH. PRs are welcome to add more. 

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
CMC_API_KEY="xxxxx-xxxx-xxxx-xxxx-xxxxx" GEMINI_API_KEY="account-XXXXXXXX" GEMINI_API_SECRET="XXXXXX" ruby crypto.rb coinhako.csv binance.json
```

## CoinMarketCAP 

* `CMC_API_KEY` is used to make API calls to determine current price for cryptos.
* Free basic plan lets you make 10K calls every month.

## Gemini 

* `GEMINI_API_KEY` and `GEMINI_API_SECRET` are used to pull transactions from Gemini via "Get Past Trades" API ( https://docs.gemini.com/rest-api/#get-past-trades )
* API key and secret can be generated via https://exchange.gemini.com/settings/api

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

## Sample Output

```
"Wrote 146 transactions to cointracker.csv"

----------------------------------------- BTC / SGD -------------------------------------------

┌───────────────────────────────────────────────────────────────────────────────────────┐
│                                         Buys                                          │
├────────────┬─────────────────────┬────────┬──────────────────────────┬────────────────┤
│ Exchange   │ BTC                 │ SGD    │ Fee                      │ # Transactions │
╞════════════╪═════════════════════╪════════╪══════════════════════════╪════════════════╡
│ Binance Sg │ 0.014184            │ 1004.0 │ 5.98 ( 0.596% )          │ 29             │
│ Coinhako   │ 0.03753064038325285 │ 2428.0 │ 21.79 ( 0.897% )         │ 63             │
│ Gemini     │ 0.01184317          │ 784.0  │ 1.9599887875 ( 0.25% )   │ 14             │
╞════════════╪═════════════════════╪════════╪══════════════════════════╪════════════════╡
│ TOTAL      │ 0.06355781038325285 │ 4216.0 │ 29.7299887875 ( 0.705% ) │ 106            │
└────────────┴─────────────────────┴────────┴──────────────────────────┴────────────────┘

Average Buy price: 66333.310958599


Total BTC owned: 0.06355781038325285 ( Bought: 0.06355781038325285, Sold: 0)

Average Own price: 66333.310958599


% fiat gain: -1.0%


----------------------------------------- DOGE / SGD -------------------------------------------

┌───────────────────────────────────────────────────────────────────────────────┐
│                                     Buys                                      │
├──────────┬─────────────────────────┬───────┬─────────────────┬────────────────┤
│ Exchange │ DOGE                    │ SGD   │ Fee             │ # Transactions │
╞══════════╪═════════════════════════╪═══════╪═════════════════╪════════════════╡
│ Coinhako │ 1445.187664780632303644 │ 652.0 │ 5.65 ( 0.867% ) │ 8              │
└──────────┴─────────────────────────┴───────┴─────────────────┴────────────────┘

Average Buy price: 0.451152480670369048845952941920314229

┌──────────────────────────────────────────────────────────────────────────────────┐
│                                      Sells                                       │
├──────────┬────────────────────────┬───────┬─────────────────────┬────────────────┤
│ Exchange │ DOGE                   │ SGD   │ Fee                 │ # Transactions │
╞══════════╪════════════════════════╪═══════╪═════════════════════╪════════════════╡
│ Coinhako │ 457.828199103371725937 │ 39.68 │ 0.29984885615026452 │ 1              │
└──────────┴────────────────────────┴───────┴─────────────────────┴────────────────┘

Average Sell price: 0.086670065491183879093265504077651657


Total DOGE owned: 987.359465677260577707 ( Bought: 1445.187664780632303644, Sold: 457.828199103371725937)

Average Own price: 0.620159142931789954115381828015633071


% fiat gain: 7.2%


----------------------------------------- BAT / SGD -------------------------------------------

┌────────────────────────────────────────────────────────────────────────────┐
│                                    Buys                                    │
├──────────┬────────────────────────┬───────┬───────────────┬────────────────┤
│ Exchange │ BAT                    │ SGD   │ Fee           │ # Transactions │
╞══════════╪════════════════════════╪═══════╪═══════════════╪════════════════╡
│ Coinhako │ 189.204812061896943076 │ 272.0 │ 2.72 ( 1.0% ) │ 6              │
└──────────┴────────────────────────┴───────┴───────────────┴────────────────┘

Average Buy price: 1.437595571887554470446377310265931605

┌───────────────────────────────────────────────────────┐
│                         Sells                         │
├──────────┬──────┬───────┬────────────┬────────────────┤
│ Exchange │ BAT  │ SGD   │ Fee        │ # Transactions │
╞══════════╪══════╪═══════╪════════════╪════════════════╡
│ Coinhako │ 27.0 │ 45.43 │ 0.36636192 │ 1              │
└──────────┴──────┴───────┴────────────┴────────────────┘

Average Sell price: 1.682592592592592592592592593


Total BAT owned: 162.204812061896943076 ( Bought: 189.204812061896943076, Sold: 27.0)

Average Own price: 1.396814293730949641452019724196725589


% fiat gain: 13.65%


----------------------------------------- ETH / SGD -------------------------------------------

┌──────────────────────────────────────────────────────────────────────────────┐
│                                     Buys                                     │
├────────────┬──────────────────────┬───────┬─────────────────┬────────────────┤
│ Exchange   │ ETH                  │ SGD   │ Fee             │ # Transactions │
╞════════════╪══════════════════════╪═══════╪═════════════════╪════════════════╡
│ Binance Sg │ 0.09069              │ 224.0 │ 1.33 ( 0.594% ) │ 7              │
│ Coinhako   │ 0.218180113718688119 │ 464.0 │ 4.32 ( 0.931% ) │ 14             │
│ Gemini     │ 0.0392               │ 196.0 │ 0.49 ( 0.25% )  │ 2              │
╞════════════╪══════════════════════╪═══════╪═════════════════╪════════════════╡
│ TOTAL      │ 0.348070113718688119 │ 884.0 │ 6.14 ( 0.695% ) │ 23             │
└────────────┴──────────────────────┴───────┴─────────────────┴────────────────┘

Average Buy price: 2539.718192279

┌─────────────────────────────────────────────────────┐
│                        Sells                        │
├────────────┬────────┬───────┬──────┬────────────────┤
│ Exchange   │ ETH    │ SGD   │ Fee  │ # Transactions │
╞════════════╪════════╪═══════╪══════╪════════════════╡
│ Binance Sg │ 0.0053 │ 19.92 │ 0.12 │ 1              │
└────────────┴────────┴───────┴──────┴────────────────┘

Average Sell price: 3758.490566037735849057


Total ETH owned: 0.342770113718688119 ( Bought: 0.348070113718688119, Sold: 0.0053)

Average Own price: 2520.873219154548541075


% fiat gain: 100.86%

```