# frozen_string_literal: true

require_relative 'coin_stack'
require_relative 'draw_tty'

class VendingMachine
  include DrawTTY
  attr_reader :items, :coin_stack, :inserted_coins

  def initialize(items = [], money = {}, coin_stack_klass = CoinStack, coin_klass = Coin)
    @items = items
    @coin_stack = coin_stack_klass.new(money, coin_klass)
    @inserted_coins = coin_stack_klass.new({}, coin_klass)
  end

  def money
    coin_stack.select { |coin| coin.quantity.positive? }
  end

  def insert_coin(coin)
    @inserted_coins.add(coin)
  end

  def purchase(code)
    raise ArgumentError, 'Please insert coins' if @inserted_coins.empty?

    code = code.rstrip.chomp.upcase if code.is_a? String
    item = items.find { |i| i[:code] == code }
    raise RangeError, 'Invalid selection!' if item.nil?
    raise RangeError, "#{item[:name]}: Out of stock!" if item[:quantity].zero?

    change = @inserted_coins.sum - item[:price]
    raise ArgumentError, 'Not enough money!' if change.negative?

    save_inserted_coins
    return_coins = coin_stack.get_return(change)
    item[:quantity] -= 1

    display_output(item, return_coins)
  end

  def add_money(coins)
    coins&.each do |denomination, quantity|
      begin
        coin_stack.add(denomination, quantity)
      rescue ArgumentError
        next
      end
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
      main_box
      output ||= ''
      handle_output_message(output) unless output.empty?
      button = gets.rstrip.chomp

      output = case button
               when 'I', 'i'
                 flash_box("Insert coin:\n#{coin_stack.coin_klass::VALID_DENOMINATION}")
                 action = gets.to_i
                 insert_coin(action)
               when 'B', 'b'
                 flash_box('Enter code:')
                 action = gets
                 purchase(action)
               when 'Q', 'q'
                 flash_box('Bye! Bye!')
                 return
      end
    end
  rescue ArgumentError, RangeError => e
    handle_output_message(e)
    gets
    run
  end

  def items_display
    items.map do |i|
      [
        i[:code],
        "£#{format('%.2f', (i[:price].to_f / 100))}",
        (i[:quantity].to_s.size == 1 ? ' ' + i[:quantity].to_s : i[:quantity]).to_s,
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
    return "Item: #{item[:name]}" if coins.empty?

    "Item: #{item[:name]}\nChange: #{coins_text(coins)}"
  end

  def coins_text(coins)
    coins.map(&:to_s).join(' + ')
  end
end
