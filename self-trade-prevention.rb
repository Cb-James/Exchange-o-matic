# Creates a self-trade-prevention scenario and reports the results
require 'coinbase/exchange' # main wrapper
require_relative 'lib/exchange' # extended functionality

# Set desired self-trade behaviour
#   cb => cancel both
#   co => cancel oldest
#   cn => cancel newest
#   dc => decrement and cancel
STP = 'dc'

# Sandbox Account #1
key = ENV['EXCHANGE_SB_ACCESS_KEY']
secret = ENV['EXCHANGE_SB_API_SECRET']
pass = ENV['EXCHANGE_SB_PASSPHRASE']

# Sandbox Account #2
alt_key = ENV['ALT_EXCHANGE_SB_ACCESS_KEY']
alt_secret = ENV['ALT_EXCHANGE_SB_API_SECRET']
alt_pass = ENV['ALT_EXCHANGE_SB_PASSPHRASE']

API_URL = 'https://api-public.sandbox.exchange.coinbase.com'

# Exchange info
rest_api = Coinbase::Exchange::Client.new(key, secret, pass, api_url: API_URL)

# Dummy account to create orders
bot = Coinbase::Exchange::Bot.new(
  key, secret, pass, api_url: API_URL)

# Self-trading customer
customer = Coinbase::Exchange::Bot.new(
  alt_key, alt_secret, alt_pass, api_url: API_URL)

# Bot places a sell order for Customer to buy
amount = '0.5'
price = rest_api.max_bid.ceil.to_i # make it higher than any existing bids
price = 100 if price == 0 # if no bids, use an even $100
puts format 'Bot sells %.2f BTC @ $%.2f', amount, price
bot.sell(amount, price, stp: STP)

# Customer places BUY for existing sell plus more
amount = '1.0'
puts format 'Customer buys %.2f BTC @ $%.2f', amount, price
customer.buy(amount, price, stp: STP) do |resp|
  @buy_id = resp.id
end

# Customer places SELL for more BTC than his buy, same price
full_amount = '1.5'
puts format 'Customer sells %.2f BTC @ $%.2f', full_amount, price
customer.sell(full_amount, price, stp: STP) do |resp|
  @sell_id = resp.id
end

# Bot fills Customer's sell
amount = '1'
puts format 'Bot buys %.2f BTC @ $%.2f', amount, price
bot.buy(amount, price, stp: STP)

# Print status for Customer's 2 orders
customer.order(@buy_id) do |resp|
  puts ''
  puts 'Order #1'
  puts '========'
  puts ''
  puts format 'Size: %.2f', resp.size
  puts "Side: #{resp.side}"
  puts "STP: #{resp.stp}"
  puts "Type: #{resp.type}"
  puts format 'Filled size: %.2f', resp.filled_size
  puts "Status: #{resp.status}"
  if resp.status == 'done'
    puts "Done reason: #{resp.done_reason}"
    puts "Settled: #{resp.settled}"
  end
end

customer.order(@sell_id) do |resp|
  puts ''
  puts 'Order #2'
  puts '========'
  puts ''
  puts format 'Size: %.2f (Original: %.2f)', resp.size, full_amount
  puts "Side: #{resp.side}"
  puts "STP: #{resp.stp}"
  puts "Type: #{resp.type}"
  puts format 'Filled size: %.2f', resp.filled_size
  puts "Status: #{resp.status}"
  if resp.status == 'done'
    puts "Done reason: #{resp.done_reason}"
    puts "Settled: #{resp.settled}"
  end
end
