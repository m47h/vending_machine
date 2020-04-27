# frozen_string_literal: true

require_relative 'coin_stack'
require 'tty-box'
require 'tty-screen'
require 'pry'

class VendingMachine
  attr_reader :items, :coin_stack, :inserted_coins

  def initialize(items, money = {}, coin_stack = CoinStack)
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
      box { "#{output}" }
      button = gets.rstrip.chomp

      output = case button
      when 'I', 'i'
        box { "Insert coin: #{Coin::VALID_DENOMINATION}" }
        action = gets.to_i
        insert_coin(action)
      when 'B', 'b'
        box { [
            "Items: #{items.map { |i| "#{i[:name]} code: #{i[:code]}, price: #{i[:price]}" }.join(', ') }",

            "Enter code:"
          ] }
        action = gets.to_i
        purchase(action)
      when 'S', 's'
        box { 'Bye! Bye!' }
        return
      end
    end
  end

  def box(&block)
    text = [
      "Vending Machine",
      "You have insert £#{inserted_coins.sum.to_f / 100}",
      "I,i = Insert Coin",
      "B,b = Buy Item",
      "S,s = Stop Machine",
    ]

    text << "" << yield if block_given?

    print TTY::Box.frame(
      text.join("\n"),
      width: TTY::Screen.width,
      height: TTY::Screen.height
    )
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

money = { 1 => 2, 2 => 3, 5 => 5 }
items = [{ code: 1, name: 'Snacks', quantity: 5, price: 100 }]
vending_machine = VendingMachine.new(items, money)
vending_machine.run
