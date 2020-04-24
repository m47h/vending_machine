# frozen_string_literal: true

require './lib/vending_machine'
require 'pry'

RSpec.describe VendingMachine do
  let(:money) { { 1 => 2, 2 => 3, 5 => 5 } }
  let(:items) { [{ code: 1, name: 'Snacks', quantity: 5, price: 100 }] }
  let(:vending_machine) { VendingMachine.new(items, money) }

  context '#insert_coin' do
    it "for nil return 'Coin invalid'" do
      expect(vending_machine.insert_coin(nil)).to eq 'Coin invalid'
    end

    it "for invalid coins return 'Coin invalid'" do
      expect(vending_machine.insert_coin('bad_coin')).to eq 'Coin invalid'
    end

    it 'valid coin are added to inserted_coins' do
      vending_machine.insert_coin(1)

      expect(vending_machine.inserted_coins[1]).to eq 1
    end
  end

  context '#purchase' do
    context 'no inserted coins' do
      it "return 'Please insert coin'" do
        expect(vending_machine.purchase(1)).to eq 'Please insert coins'
      end
    end
    context 'inserted_money = 50p' do
      before do
        vending_machine.insert_coin(50)
      end

      it "for nil return 'Invalid selection'" do
        expect(vending_machine.purchase(nil)).to eq 'Invalid selection!'
      end

      it "for invalid code return 'Invalid selection'" do
        expect(vending_machine.purchase('bad_code')).to eq 'Invalid selection!'
      end

      it "when not enough money is provided return 'Not enough money!'" do
        expect(vending_machine.purchase(1)).to eq 'Not enough money!'
      end

      it 'item out of stock' do
        items.first[:quantity] = 0

        expect(vending_machine.purchase(1)).to eq "#{items.first[:name]}: Out of stock!"
      end

      # default 50p + 50
      it 'for valid amount of money it return item' do
        vending_machine.insert_coin(50)

        expect(vending_machine.purchase(1)).to eq "Please take your: #{items.first[:name]}"
      end

      it 'when provided amount of money exceed item price it return item and change' do
        coins = [50, 10, 2, 1]
        coins.each { |coin| vending_machine.insert_coin(coin) }

        expect(vending_machine.purchase(1))
          .to eq "Please take your: #{items.first[:name]} and 1 x 10p + 1 x 2p + 1 x 1p change."
      end

      it 'after purchase it saves insert coins into machine stock' do
        vending_machine.insert_coin(100)
        vending_machine.purchase(1)

        expect(vending_machine.money[100]).to eq 1
      end

      it 'after purchase money is correct' do
        vending_machine.insert_coin(100)
        vending_machine.purchase(1)

        expect(vending_machine.money).to eq(1 => 2, 2 => 3, 5 => 5, 100 => 1)
      end
    end
  end

  context '#add_money' do
    it 'nil do nothing' do
      new_money = nil
      vending_machine.add_money(new_money)

      expect(vending_machine.money).to eq(money)
    end

    it 'increase quantity' do
      new_money = { 1 => 5, 5 => 5, 10 => 3, 200 => 1 }
      vending_machine.add_money(new_money)

      expect(vending_machine.money).to eq(1 => 7, 2 => 3, 5 => 10, 10 => 3, 200 => 1)
    end

    it 'invalid coins are skipped' do
      new_money = { 7 => 3, 15 => 1 }
      vending_machine.add_money(new_money)

      expect(vending_machine.money).to eq(money)
    end
  end

  context '#add_items' do
    it 'for nil do nothing' do
      new_items = nil
      vending_machine.add_items(new_items)

      expect(vending_machine.items).to eq items
    end

    it 'add new items' do
      new_items = [{ code: 'new', name: 'new' }]
      vending_machine.add_items(new_items)

      expect(vending_machine.items.last).to include(code: 'new')
    end

    it 'increase quantity of existing item' do
      new_items = [{ code: 1, name: 'Snacks', quantity: 5, price: 100 }]
      vending_machine.add_items(new_items)

      expect(vending_machine.items.first[:quantity]).to eq 10
    end
  end

  context 'check if #get_return_coins' do
    attempts = [
      { price: 90, inserted_coins: [100], return_coins: { 5 => 2 } },
      { price: 2, inserted_coins: [10], return_coins: { 5 => 1, 2 => 1, 1 => 1 } },
      {
        price: 80,
        inserted_coins: [100, 100],
        add_money: { 100 => 1, 10 => 1 },
        return_coins: { 100 => 1, 10 => 1, 5 => 2 }
      },
      {
        price: 70,
        inserted_coins: [200, 10, 10],
        add_money: { 20 => 5, 10 => 1 },
        return_coins: { 20 => 5, 10 => 3, 5 => 4 }
      },
      {
        price: 164,
        inserted_coins: [200, 100, 50, 50],
        return_coins: { 200 => 1, 5 => 5, 2 => 3, 1 => 2 }
      }
    ]

    attempts.each do |attempt|
      it "return correct amount of coins for Item_#{attempt[:price]}" do
        vending_machine.add_items([
          code: 2, name: "Item_#{attempt[:price]}", quantity: 5, price: attempt[:price]
        ])
        vending_machine.add_money(attempt[:add_money])
        attempt[:inserted_coins].each { |coin| vending_machine.insert_coin(coin) }

        expect(vending_machine.purchase(2))
          .to eq "Please take your: Item_#{attempt[:price]} and #{coins_text(attempt[:return_coins])} change."
      end
    end

    context 'when machine have not enough coins' do
      before do
        items << { code: 2, name: 'Cookies', quantity: 5, price: 1 }
        vending_machine.insert_coin(200)
      end

      it 'return all coins' do
        expect(vending_machine.purchase(2))
          .to eq 'Please take your: Cookies and 5 x 5p + 3 x 2p + 2 x 1p change.'
      end

      it 'leave in in machine is last inserted coin' do
        vending_machine.purchase(2)

        expect(vending_machine.money).to eq(200 => 1)
      end
    end
  end

  context '#save_inserted_coins' do
    it 'reset @inserted_coins' do
      vending_machine.insert_coin(50)
      vending_machine.insert_coin(20)
      vending_machine.insert_coin(20)
      vending_machine.insert_coin(10)

      expect { vending_machine.purchase(1) }
        .to change { vending_machine.inserted_coins }
        .from(50 => 1, 20 => 2, 10 => 1).to({})
    end
  end
end

def coins_text(coins)
  VendingMachine.new([], []).send :coins_text, coins
end
