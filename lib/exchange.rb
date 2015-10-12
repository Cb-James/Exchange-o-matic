# Extended functionality beyond the official Coinbase Exchange
# wrapper @ https://github.com/coinbase/coinbase-exchange-ruby
module Coinbase
  module Exchange
    # Extensions on the main class
    class Client
      def max_bid
        bids = JSON.parse(orderbook(level: 3))['bids']
        bids.count > 0 ? bids.flat_map { |bid| bid[0].to_f }.max : 0
      end

      def min_bid
        bids = JSON.parse(orderbook(level: 3))['bids']
        bids.count > 0 ? bids.flat_map { |bid| bid[0].to_f }.min : 0
      end

      def max_ask
        asks = JSON.parse(orderbook(level: 3))['asks']
        asks.count > 0 ? asks.flat_map { |bid| bid[0].to_f }.max : 0
      end

      def min_ask
        asks = JSON.parse(orderbook(level: 3))['asks']
        asks.count > 0 ? asks.flat_map { |bid| bid[0].to_f }.min : 0
      end
    end

    # Bot-type functionality goes here
    class Bot < Client
      def account_id(currency)
        accounts do |resp|
          @record = resp.select { |account| account.currency == currency }[0]
        end
        @record['id']
      end

      def holds_balance(currency, balance = BigDecimal('0'))
        account_id = account_id(currency)
        account_holds(account_id) do |holds|
          if holds.count > 0
            balance = holds.flat_map do |hold|
              BigDecimal(hold.amount)
            end.reduce(:+)
          end
        end
        balance
      end

      def balance(currency)
        accounts do |resp|
          @record = resp.select { |account| account.currency == currency }[0]
        end
        BigDecimal(@record['balance']) - holds_balance(currency)
      end

      def replenish(currency, amount, wallet)
        currency == 'BTC' ? precision = 8 : precision = 2
        deposit_amount = BigDecimal(amount).truncate(precision).to_s('F')
        deposit(wallet, deposit_amount)
      end

      def wait
        sleep 5
      end
    end
  end
end
