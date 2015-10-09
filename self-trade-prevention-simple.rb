# This script creates a self-trade-prevention scenario to see how the Exchange handles it

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

# Self-trading customer
customer = Coinbase::Exchange::Client.new(key, secret, pass,
  api_url: 'https://api-public.sandbox.exchange.coinbase.com')

# Find the smallest price on the orderbook, and set ours below it
price = [ Exchange.min_bid_price(customer), Exchange.min_ask_price(customer) ].min
puts sprintf "Lowest price: #{price}"
price.to_f > 1 ? price = '1.69' : price = '0.00'

# Place a small buy
amount = '0.01'
puts sprintf "Customer buys %.2f BTC @ $%.2f", amount, price
customer.buy(amount, price, stp: STP) do |resp|
  @buy_id = resp.id
end

sleep 5

# Place a small sell
puts sprintf "Customer sells %.2f BTC @ $%.2f", amount, price
customer.sell(amount, price, stp: STP) do |resp|
  @sell_id = resp.id
end

# Print status for Customer's 2 orders
customer.order(@buy_id) do |resp|
  puts ""
  puts "Order #1"
  puts "========"
  puts ""
  puts sprintf "Size: %.2f", resp.size
  puts "Side: #{resp.side}"
  puts "STP: #{resp.stp}"
  puts "Type: #{resp.type}"
  puts sprintf "Filled size: %.2f", resp.filled_size
  puts "Status: #{resp.status}"
  if resp.status == "done"
    puts "Done reason: #{resp.done_reason}"
    puts "Settled: #{resp.settled}"
  end
end

customer.order(@sell_id) do |resp|
  puts ""
  puts "Order #2"
  puts "========"
  puts ""
  puts sprintf "Size: %.2f", resp.size
  puts "Side: #{resp.side}"
  puts "STP: #{resp.stp}"
  puts "Type: #{resp.type}"
  puts sprintf "Filled size: %.2f", resp.filled_size
  puts "Status: #{resp.status}"
  if resp.status == "done"
    puts "Done reason: #{resp.done_reason}"
    puts "Settled: #{resp.settled}"
  end
end
