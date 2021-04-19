# crypto

# usage
ruby crypto.rb <path/to/coinhako/csv> <path/to/binance/json> 

# coinhako input csv file

Login to coinhako.com, goto "Trade History" page(https://www.coinhako.com/wallet/history/trade) and download csv

# binance input json file

Login to binance.sg, goto "History -> Buy/Sell" (https://www.binance.sg/en/usercenter/history/buysell)
Open dev tools (Cmd + Shift + I)
Copy the response of the API call https://www.binance.sg/gateway-api/v1/private/ocbs/get-user-payment-history
Copy the array from "data.rows.dataList" into a json file


