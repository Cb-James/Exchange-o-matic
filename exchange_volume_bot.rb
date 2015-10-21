require 'coinbase/exchange'
require 'slack-notifier'

notifier = Slack::Notifier.new ENV['WEBHOOK_URL'],
                               channel: '#channel', username: 'bot'

key = ENV['CBX_V_KEY']
secret = ENV['CBX_V_SECRET']
pass = ENV['CBX_V_PASSPHRASE']

THRESHOLD = 10
POLLING_INTERVAL = 1 * 60 * 60 # 1 hour

rest_api = Coinbase::Exchange::Client.new(key, secret, pass)
last_volume = JSON.parse(rest_api.daily_stats)['volume']

loop do
  volume = JSON.parse(rest_api.daily_stats)['volume']
  difference = last_volume.to_i - volume.to_i
  puts "Last #{last_volume} / Now: #{volume}"
  if difference > THRESHOLD
    message = "Lost #{difference} BTC volume in the last " \
      "#{POLLING_INTERVAL / 60} minutes."
    notifier.ping(message)
  end
  last_volume = volume
  sleep POLLING_INTERVAL
end
