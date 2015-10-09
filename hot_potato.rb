# Creates two bots on the Sandbox and buys and sells endlessly between them 
require 'coinbase/exchange' # main wrapper
require_relative 'lib/exchange' # extended functionality

# Sandbox Account #1
key = ENV['EXCHANGE_SB_ACCESS_KEY']
secret = ENV['EXCHANGE_SB_API_SECRET']
pass = ENV['EXCHANGE_SB_PASSPHRASE']

# Sandbox Account #2
alt_key = ENV['ALT_EXCHANGE_SB_ACCESS_KEY']
alt_secret = ENV['ALT_EXCHANGE_SB_API_SECRET']
alt_pass = ENV['ALT_EXCHANGE_SB_PASSPHRASE']

# Alice sells
alice = Coinbase::Exchange::Client.new(key, secret, pass,
  api_url: 'https://api-public.sandbox.exchange.coinbase.com')

# Bob buys
bob = Coinbase::Exchange::Client.new(alt_key, alt_secret, alt_pass,
  api_url: 'https://api-public.sandbox.exchange.coinbase.com')

while true  # infinite loop!
  # Buy/Sell higher than existing orders
  max_bid = Exchange.max_bid(alice).to_f

  # Use random amounts within a range  
  sale_price = BigDecimal(rand(max_bid + 0.01..max_bid + 100).to_s)
  btc_amount = BigDecimal(rand(1.00..3.00).to_s)
  usd_amount = sale_price * btc_amount * BigDecimal('1.25')

  # Top up accounts if nessesary
  alice.replenish('BTC', btc_amount) if alice.balance('BTC') < btc_amount
  bob.replenish('USD', usd_amount) if bob.balance('USD') < usd_amount
  
  # Sell!
  puts sprintf "Alice selling %.8f BTC @ $%.2f", btc_amount, sale_price
  alice.sell(btc_amount.round(8), sale_price.round(2))

  sleep 5
  
  # Buy!  
  puts sprintf "Bob buying %.8f BTC @ $%.2f", btc_amount, sale_price
  bob.buy(btc_amount.round(8), sale_price.round(2))

  sleep 5
end
