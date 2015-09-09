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
  max_bid_price = Exchange.max_bid_price(alice).to_f

  # Use random amounts within a range  
  sale_price = BigDecimal(rand(max_bid_price + 0.01..max_bid_price + 100).to_s)
  btc_amount = BigDecimal(rand(1.00..3.00).to_s)
  usd_amount = sale_price * btc_amount

  # Top up accounts if nessesary
  Exchange.replenish_btc(alice, btc_amount) if Exchange.balance(alice, 'BTC') < btc_amount
  Exchange.replenish_usd(bob, usd_amount) if Exchange.balance(bob, 'USD') < usd_amount
  
  # Sell!
  puts sprintf "Selling %.8f BTC @ $%.2f", btc_amount, sale_price
  alice.sell(btc_amount.round(8), sale_price.round(2))

  # Buy!  
  puts sprintf "Buying %.8f BTC @ $%.2f", btc_amount, sale_price
  bob.buy(btc_amount.round(8), sale_price.round(2))
end
