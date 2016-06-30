# Good till time (GTT) test
require 'coinbase/exchange'

key = ENV['EXCHANGE_SB_ACCESS_KEY']
secret = ENV['EXCHANGE_SB_API_SECRET']
pass = ENV['EXCHANGE_SB_PASSPHRASE']
API_URL = 'https://api-public.sandbox.exchange.coinbase.com'

rest_api = Coinbase::Exchange::Client.new(key, secret, pass, api_url: API_URL)
puts 'Placing buy order...'
rest_api.buy('1.0', 100, time_in_force: 'GTT', cancel_after: 1) do |resp|
  @buy_id = resp.id
end

sleep 2

rest_api.order(@buy_id) do |resp|
  puts 'Order Status:'
  puts format '- size: %.2f', resp.size
  puts "- side: #{resp.side}"
  puts "- time in force: #{resp.time_in_force}"
  puts "- type: #{resp.type}"
  puts format '- filled size: %.2f', resp.filled_size
  puts "- status: #{resp.status}"
  if resp.status == 'done'
    puts "- done reason: #{resp.done_reason}"
    puts "- settled: #{resp.settled}"
  end
end
