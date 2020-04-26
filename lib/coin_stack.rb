# frozen_string_literal: true

require_relative 'coin'

class CoinStack
  include Enumerable
  attr_reader :stack

  def initialize(money = {})
    @stack = fill_with(money)
  end

  def [](denomination)
    @stack.find { |coin| coin.denomination == denomination }
  end

  def []=(denomination, quantity)
    coin = @stack.find { |coin| coin.denomination == denomination }
    return add(denomination, quantity) unless coin

    coin.quantity = quantity
  end

  def +(other)
    return unless self.class == other.class

    other.each { |coin| add(coin.denomination, coin.quantity) }
  end

  def <=>(other)
    sum <=> other.sum
  end

  def return_coins(coins)
    coins.each { |coin| self[coin.denomination] - coin.quantity }
  end

  def drop!
    @stack = []
  end

  def empty?
    @stack.empty?
  end

  def sum
    @stack.inject(0) { |sum, coin| sum + coin.denomination * coin.quantity }
  end

  def compact!
    @stack.select! { |element| element.is_a?(Coin) && element.quantity != 0 }
  end

  def each(&block)
    if block_given?
      @stack.each(&block)
    else
      to_enum(:each)
    end
  end

  def to_h
    compact!
    Hash[@stack.sort.reverse.map { |coin| [coin.denomination, coin.quantity] }]
  end

  def add(denomination, quantity = 1)
    return 'Please add coins' if quantity.negative?
    return 'Coin invalid' unless Coin.valid?(denomination)

    return self[denomination] + quantity if self[denomination]

    @stack << Coin.new(denomination, quantity)
  end

  def inspect
    stack.inspect
  end

  def get_return(change)
    # select denomination smaller or equal change
    # sort descending by denomination
    coins = @stack
            .select { |coin| coin.denomination <= change && coin.quantity.positive? }
            .sort.reverse
            .map!(&:dup) # count on current stack but dont change it

    unless coins.empty?
      min_return_coins = minimal_coins_to_change(change, coins)

      coin = coins.first
      coin.quantity > 1 ? coin - 1 : coins.delete_if { |c| c.denomination == coin.denomination }
    end

    min_return_coins || {}
  end

  private

  def minimal_coins_to_change(change, coins)
    return_coins = []
    min_change = change
    min_return_coins = coins

    coins.each do |coin|
      max_quantity = (change / coin.denomination).to_i
      return_quantity = [max_quantity, coin.quantity].min
      next if return_quantity.zero?

      # return_coins[coin.denomination] = return_quantity
      return_coins << Coin.new(coin.denomination, return_quantity)
      change -= coin.denomination * return_quantity

      if change < min_change
        min_change = change
        min_return_coins = return_coins
      end
      break if change.zero?
    end

    min_return_coins
  end

  def fill_with(money)
    money.map do |denomination, quantity|
      Coin.new(denomination, quantity) if Coin.valid?(denomination)
    end
  end
end
