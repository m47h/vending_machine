# frozen_string_literal: true

class VendingMachine
  VALID_COINS = [1, 2, 5, 10, 20, 50, 100, 200].freeze
  attr_reader :items, :inserted_coins

  def initialize(items, money)
    @items = items
    @money = money
    @inserted_coins = {}
  end

  def money
    @money.select { |_, quantity| quantity.positive? }
  end

  def insert_coin(coin)
    return 'Coin invalid' unless coin_valid?(coin)

    @inserted_coins[coin] = 0 unless @inserted_coins[coin]
    @inserted_coins[coin] += 1
  end

  def purchase(code)
    return 'Please insert coins' if @inserted_coins.empty?

    item = items.find { |i| i[:code] == code }
    return 'Invalid selection!' if item.nil?
    return "#{item[:name]}: Out of stock!" if item[:quantity].zero?

    change = sum_coins(@inserted_coins) - item[:price]
    return 'Not enough money!' if change.negative?

    save_inserted_coins
    return_coins = get_return_coins(change)
    from_machine_remove(return_coins)
    item[:quantity] -= 1

    display_output(item, return_coins)
  end

  def add_money(coins)
    return if coins.nil?

    coins.each do |denomination, quantity|
      next unless coin_valid?(denomination)

      @money[denomination] = 0 unless @money[denomination]
      @money[denomination] += quantity
    end
  end

  def add_items(new_items)
    return if new_items.nil?

    new_items.each do |new_item|
      item = items.find { |i| i[:code] == new_item[:code] }
      if item
        item[:quantity] += new_item[:quantity]
      else
        items << new_item
      end
    end
  end

  private

  def coin_valid?(coin)
    VALID_COINS.include?(coin)
  end

  def sum_coins(coins)
    coins.inject(0) { |sum, (key, value)| sum + key * value }
  end

  def save_inserted_coins
    @inserted_coins.each do |denomination, quantity|
      @money[denomination] = 0 unless @money[denomination]
      @money[denomination] += quantity
    end
    @inserted_coins = {}
  end

  def from_machine_remove(coins)
    coins.each { |denomination, quantity| @money[denomination] -= quantity }
  end

  def display_output(item, coins)
    return "Please take your: #{item[:name]}" if coins.empty?

    "Please take your: #{item[:name]} and #{coins_text(coins)} change."
  end

  def coins_text(coins)
    coins.map { |k, v| "#{v} x #{denomination_name(k)}" }.join(' + ')
  end

  def denomination_name(denomination)
    return "£#{denomination / 100}" if denomination >= 100

    "#{denomination}p"
  end

  def get_return_coins(change)
    # sort @money descending by denomination
    @money.keys.sort.reverse.each { |k| @money[k] = @money.delete k }
    # select not null coins with denomination smaller or equal change
    coins = @money.select { |denomination, _| denomination <= change }

    unless coins.empty?
      min_return_coins = minimum_change_and_coins(change, coins)

      denomination, quantity = coins.first
      quantity > 1 ? coins[denomination] -= 1 : coins.delete(denomination)
    end

    min_return_coins || {}
  end

  def minimum_change_and_coins(change_left, coins)
    return_coins = {}
    min_change_left = change_left
    min_return_coins = coins

    coins.each do |denomination, quantity|
      max_quantity = (change_left / denomination).to_i
      return_quantity = [max_quantity, quantity].min
      next if return_quantity.zero?

      return_coins[denomination] = return_quantity
      change_left -= denomination * return_quantity

      if change_left < min_change_left
        min_change_left = change_left
        min_return_coins = return_coins
      end
      break if change_left.zero?
    end

    min_return_coins
  end
end
