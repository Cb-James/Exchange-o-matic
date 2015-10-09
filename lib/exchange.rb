# Extended functionality beyond the official Coinbase Exchange
# wrapper @ https://github.com/coinbase/coinbase-exchange-ruby

module Coinbase
  module Exchange
    class Client
      def account_id(currency)
        self.accounts do |resp|
          @record = resp.select { |account| account.currency == currency }[0]
        end
        @record['id']
      end

      def holds_balance(currency, balance = BigDecimal('0'))
        account_id = self.account_id(currency)
        self.account_holds(account_id) do |resp|
          balance = resp.flat_map { |hold| BigDecimal(hold.amount) }.reduce(:+) if resp.count > 0
        end
        balance
      end

      def balance(currency, balance = BigDecimal('0'))
        self.accounts do |resp|
          @record = resp.select { |account| account.currency == currency }[0]
        end
        balance = BigDecimal(@record['balance']) - self.holds_balance(currency)
      end
    
      def replenish(currency, amount)
        case currency
        when 'BTC'
          wallet = "95671473-4dda-5264-a654-fc6923e8a334" # Official Sandbox fake BTC wallet
          deposit_amount = (amount + BigDecimal('10')).truncate(8).to_s('F')
          puts sprintf "Depositing %.8f BTC", deposit_amount
        when 'USD'
          wallet = "bcdd4c40-df40-5d76-810c-74aab722b223" # Official Sandbox fake USD wallet
          deposit_amount = (amount + BigDecimal('1000')).truncate(2).to_s('F')
          puts sprintf "Depositing $%.2f", deposit_amount
        else
          raise 'Please specify BTC or USD'
        end
        self.deposit(wallet, deposit_amount)
      end
    end
  end
end

class Exchange
  def self.max_bid(trader)
    book = JSON.parse(trader.orderbook(level: 3))
    book['bids'].count > 0 ? book['bids'].flat_map { |bid| bid[0].to_f }.max : 0
  end

  def self.min_bid(trader)
    book = JSON.parse(trader.orderbook(level: 3))
    book['bids'].count > 0 ? book['bids'].flat_map { |bid| bid[0].to_f }.min : 0
  end

  def self.max_ask(trader)
    book = JSON.parse(trader.orderbook(level: 3))
    book['asks'].count > 0 ? book['asks'].flat_map { |bid| bid[0].to_f }.max : 0
  end

  def self.min_ask(trader)
    book = JSON.parse(trader.orderbook(level: 3))
    book['asks'].count > 0 ? book['asks'].flat_map { |bid| bid[0].to_f }.min : 0
  end
end
