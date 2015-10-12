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

API_URL = 'https://api-public.sandbox.exchange.coinbase.com'

# Official Sandbox Fake Money Wallets
wallet = { 'usd' => 'bcdd4c40-df40-5d76-810c-74aab722b223',
           'btc' => '95671473-4dda-5264-a654-fc6923e8a334' }

# Orderbook info, etc.
rest_api = Coinbase::Exchange::Client.new(
  key, secret, pass, api_url: API_URL)

# Alice the bot
alice = Coinbase::Exchange::Bot.new(
  key, secret, pass, api_url: API_URL)

# Bob the bot
bob = Coinbase::Exchange::Bot.new(
  alt_key, alt_secret, alt_pass, api_url: API_URL)

loop do
  # Buy/Sell higher than existing orders
  max_bid = rest_api.max_bid

  fee = 1.25
  # Random amounts make pretty graphs
  sale_price = BigDecimal(rand(max_bid + 0.01..max_bid + 100).to_s)
  btc_amount = BigDecimal(rand(1.00..3.00).to_s)
  usd_amount = BigDecimal(sale_price * btc_amount * fee)

  # Top up accounts (plus a little more) if nessesary
  if alice.balance('BTC') < btc_amount
    puts format 'Depositing %.8f BTC', btc_amount + 10
    alice.replenish('BTC', btc_amount + 10, wallet['btc'])
  end

  if bob.balance('USD') < usd_amount
    puts format 'Depositing $%.2f', usd_amount + 1000
    bob.replenish('USD', usd_amount + 1000, wallet['usd'])
  end

  # Sell!
  puts format 'Alice selling %.8f BTC @ $%.2f', btc_amount, sale_price
  alice.sell(btc_amount.round(8), sale_price.round(2))
  alice.wait

  # Buy!
  puts format 'Bob buying %.8f BTC @ $%.2f', btc_amount, sale_price
  bob.buy(btc_amount.round(8), sale_price.round(2))
  bob.wait
end
