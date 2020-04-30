# frozen_string_literal: true

require_relative 'coin'

class CoinStack
  # class QuantityNotPositive < StandardError; end

  include Enumerable
  attr_reader :stack, :coin_klass

  def initialize(money = {}, coin_klass = Coin)
    @coin_klass = coin_klass
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
    return @stack.each(&block) if block_given?

    to_enum(:each)
  end

  def to_h
    compact!
    Hash[@stack.sort.reverse.map { |coin| [coin.denomination, coin.quantity] }]
  end

  def add(denomination, quantity = 1)
    raise ArgumentError, 'Quantity must be positive' unless quantity.positive?
    raise ArgumentError, 'Coin invalid' unless @coin_klass.valid?(denomination)

    if self[denomination]
      self[denomination] + quantity
    else
      @stack << Coin.new(denomination, quantity)
    end
    'Coin added'
  end

  def remove(coins)
    coins&.each { |coin| self[coin.denomination] - coin.quantity }
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
      coins = remove_first_coin(coins)
    end
    remove(min_return_coins)

    min_return_coins || {}
  end

  private

  def remove_first_coin(coins)
    coin = coins.first
    coin.quantity > 1 ? coin - 1 : coins.delete_if { |c| c.denomination == coin.denomination }
    coins
  end

  def minimal_coins_to_change(change, coins)
    return_coins = self.class.new
    min_change = change
    min_return_coins = coins

    coins.each do |coin|
      min_return_quantity = minimal_return_quantity(coin, change)
      next if min_return_quantity.zero?

      return_coins.add(coin.denomination, min_return_quantity)
      change -= coin.denomination * min_return_quantity

      if change < min_change
        min_change = change
        min_return_coins = return_coins
      end
      break if change.zero?
    end

    min_return_coins
  end

  def minimal_return_quantity(coin, change)
    max_quantity = (change / coin.denomination).to_i
    [max_quantity, coin.quantity].min
  end

  def fill_with(money)
    money.map do |denomination, quantity|
      @coin_klass.new(denomination, quantity) if @coin_klass.valid?(denomination)
    end
  end
end
