# Creates a self-trade-prevention scenario and reports the results
require 'coinbase/exchange' # main wrapper
require_relative 'lib/exchange' # extended functionality

# Set desired self-trade behaviour
#   cb => cancel both
#   co => cancel oldest
#   cn => cancel newest
#   dc => decrement and cancel
STP = 'cb'

key = ENV['EXCHANGE_SB_ACCESS_KEY']
secret = ENV['EXCHANGE_SB_API_SECRET']
pass = ENV['EXCHANGE_SB_PASSPHRASE']
API_URL = 'https://api-public.sandbox.exchange.coinbase.com'

# Exchange info
rest_api = Coinbase::Exchange::Client.new(key, secret, pass, api_url: API_URL)

# Self-trading customer
customer = Coinbase::Exchange::Bot.new(key, secret, pass, api_url: API_URL)

# Find the smallest price on the orderbook, and set ours below it
price = [rest_api.min_bid, rest_api.min_ask].min
puts format "Lowest price: #{price}"
price == 0 ? price = '1.69' : price = (price - 0.01).round(2).to_s

# Place a small buy
amount = '0.01'
puts format 'Customer buys %.2f BTC @ $%.2f', amount, price
customer.buy(amount, price, stp: STP) do |resp|
  @buy_id = resp.id
end

customer.wait

# Place a small sell
puts format 'Customer sells %.2f BTC @ $%.2f', amount, price
customer.sell(amount, price, stp: STP) do |resp|
  @sell_id = resp.id
end

customer.wait

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
