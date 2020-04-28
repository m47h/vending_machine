# frozen_string_literal: true

require_relative 'coin_stack'
require_relative 'draw_tty'

class VendingMachine
  include DrawTTY
  attr_reader :items, :coin_stack, :inserted_coins

  def initialize(items, money = { }, coin_stack = CoinStack)
    @items = items
    @coin_stack = coin_stack.new(money)
    @inserted_coins = coin_stack.new
  end

  def money
    coin_stack.select { |coin| coin.quantity.positive? }
  end

  def insert_coin(coin)
    @inserted_coins.add(coin)
  end

  def purchase(code)
    code = code.rstrip.chomp if code.is_a? String
    return 'Please insert coins' if @inserted_coins.empty?

    item = items.find { |i| i[:code] == code }
    return 'Invalid selection!' if item.nil?
    return "#{item[:name]}: Out of stock!" if item[:quantity].zero?

    change = @inserted_coins.sum - item[:price]
    return 'Not enough money!' if change.negative?

    save_inserted_coins
    return_coins = coin_stack.get_return(change)
    coin_stack.return_coins(return_coins)
    item[:quantity] -= 1

    display_output(item, return_coins)
  end

  def add_money(coins)
    coins&.each do |denomination, quantity|
      coin_stack.add(denomination, quantity)
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

  def run
    while true
      output ||= ''
      main_box { "#{output}" }
      button = gets.rstrip.chomp

      output = case button
      when 'I', 'i'
        main_box { "Insert coin: #{Coin::VALID_DENOMINATION}" }
        action = gets.to_i
        insert_coin(action)
      when 'B', 'b'
        main_box { "Enter code:" }
        action = gets
        purchase(action)
      when 'Q', 'q'
        main_box { 'Bye! Bye!' }
        return
      end
    end
  end

  def items_display
    items.map do |i|
      [
        i[:code],
        "£#{'%.2f' % (i[:price].to_f / 100)}",
        "#{i[:quantity].to_s.size == 1 ? ' ' + i[:quantity].to_s : i[:quantity]}",
        i[:name]
      ].join(' :: ')
    end.join("\n")
  end

  private

  def save_inserted_coins
    coin_stack + inserted_coins
    @inserted_coins.drop!
  end

  def display_output(item, coins)
    return "Please take your: #{item[:name]}" if coins.empty?

    "Please take your: #{item[:name]} and #{coins_text(coins)} change."
  end

  def coins_text(coins)
    coins.map(&:to_s).join(' + ')
  end
end
