# Extended functionality beyond the official Coinbase Exchange
# wrapper @ https://github.com/coinbase/coinbase-exchange-ruby

class Exchange
  def self.account_id(trader, currency)
    trader.accounts do |resp|
      @record = resp.select { |account| account.currency == currency }[0]
    end
    @record['id']
  end

  def self.holds_balance(trader, currency, balance = BigDecimal('0'))
    account_id = self.account_id(trader, currency)
    trader.account_holds(account_id) do |resp|
      balance = resp.flat_map { |hold| BigDecimal(hold.amount) }.reduce(:+) if resp.count > 0
    end
    balance
  end

  def self.balance(trader, currency, balance = BigDecimal('0'))
    trader.accounts do |resp|
      @record = resp.select { |account| account.currency == currency }[0]
    end
    balance = BigDecimal(@record['balance']) - self.holds_balance(trader, currency)
  end

  def self.available_btc(book)
    book['asks'].count > 0 ? book['asks'].flat_map {|ask| ask[1].to_f }.reduce(:+) : 0
  end

  def self.max_bid_price(trader)
    book = JSON.parse(trader.orderbook(level: 3))
    book['bids'].count > 0 ? book['bids'].flat_map { |bid| bid[0].to_f }.max : 0
  end

  def self.replenish_btc(trader, btc_amount)
    wallet = "95671473-4dda-5264-a654-fc6923e8a334" # Official Sandbox fake BTC wallet       
    deposit_amount = (btc_amount + BigDecimal('10')).truncate(8).to_s('F')
    puts sprintf "Depositing %.8f BTC", deposit_amount
    trader.deposit(wallet, deposit_amount)
  end

  def self.replenish_usd(trader, usd_amount)
    wallet = "bcdd4c40-df40-5d76-810c-74aab722b223" # Official Sandbox fake USD wallet
    deposit_amount = (usd_amount + BigDecimal('1000')).truncate(2).to_s('F')
    puts sprintf "Depositing $%.2f", deposit_amount
    trader.deposit(wallet, deposit_amount)
  end
end
