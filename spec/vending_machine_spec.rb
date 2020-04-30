# frozen_string_literal: true

require './lib/vending_machine'

RSpec.describe VendingMachine do
  let(:money) { { 1 => 2, 2 => 3, 5 => 5 } }
  let(:items) { [{ code: 1, name: 'Snacks', quantity: 5, price: 100 }] }
  let(:vending_machine) { VendingMachine.new(items, money) }

  context '#purchase' do
    context 'no inserted coins' do
      it "return 'Please insert coin'" do
        expect { vending_machine.purchase(1) }
          .to raise_error(ArgumentError, 'Please insert coins')
      end
    end
    context 'inserted_money = 50p' do
      before do
        vending_machine.insert_coin(50)
      end

      it "for nil return 'Invalid selection'" do
        expect { vending_machine.purchase(nil) }
          .to raise_error(RangeError, 'Invalid selection!')
      end

      it "for invalid code return 'Invalid selection'" do
        expect { vending_machine.purchase('bad_code') }
          .to raise_error(RangeError, 'Invalid selection!')
      end

      it "when not enough money is provided return 'Not enough money!'" do
        expect { vending_machine.purchase(1) }
          .to raise_error(ArgumentError, 'Not enough money!')
      end

      it 'item out of stock' do
        items.first[:quantity] = 0

        expect { vending_machine.purchase(1) }
          .to raise_error(RangeError, "#{items.first[:name]}: Out of stock!")
      end

      # default 50p + 50
      it 'for valid amount of money it return item' do
        vending_machine.insert_coin(50)

        expect(vending_machine.purchase(1))
          .to eq success_output(items.first[:name])
      end

      it 'when provided amount of money exceed item price it return item and change' do
        coins = [50, 10, 2, 1]
        coins.each { |coin| vending_machine.insert_coin(coin) }

        expect(vending_machine.purchase(1))
          .to eq success_output(items.first[:name], { 10 => 1, 2 => 1, 1 => 1 })
      end

      it 'after purchase it saves insert coins into machine stock' do
        vending_machine.insert_coin(100)
        vending_machine.purchase(1)

        expect(vending_machine.coin_stack[100]).to eq 1
      end

      it 'after purchase money is correct' do
        vending_machine.insert_coin(100)
        vending_machine.purchase(1)

        expect(vending_machine.coin_stack.to_h).to eq(1 => 2, 2 => 3, 5 => 5, 100 => 1)
      end
    end

    context 'return correct amount and denomination of coins' do
      attempts = [
        {
          price: 8,
          inserted_coins: [20],
          machine_coins: { 5 => 3, 2 => 10, 1 => 5 },
          return_coins: { 5 => 2, 2 => 1 }
        },
        {
          price: 11,
          inserted_coins: [20],
          machine_coins: { 10 => 1, 1 => 10 },
          return_coins: { 1 => 9 }
        },
        {
          price: 65,
          inserted_coins: [200],
          machine_coins: { 20 => 10, 10 => 5, 5 => 5 },
          return_coins: { 20 => 6, 10 => 1, 5 => 1 }
        },
        {
          price: 80,
          inserted_coins: [100, 100],
          machine_coins: { 20 => 1 },
          return_coins: { 100 => 1, 20 => 1 }
        },
        {
          price: 90,
          inserted_coins: [100],
          machine_coins: { 5 => 2 },
          return_coins: { 5 => 2 }
        },
        {
          price: 164,
          inserted_coins: [200, 100, 50, 50],
          machine_coins: { 5 => 10, 2 => 5, 1 => 5 },
          return_coins: { 200 => 1, 5 => 7, 1 => 1 }
        },
        {
          price: 181,
          inserted_coins: [200, 200],
          machine_coins: { 5 => 10, 2 => 1, 1 => 5 },
          return_coins: { 200 => 1, 5 => 3, 2 => 1, 1 => 2 }
        }
      ]

      attempts.each do |attempt|
        it "for item with price #{attempt[:price]}" do
          vending_machine.coin_stack.drop!
          vending_machine.add_items([
                                      code: 2, name: "Item_#{attempt[:price]}", quantity: 5, price: attempt[:price]
                                    ])
          vending_machine.add_money(attempt[:machine_coins])
          attempt[:inserted_coins].each { |coin| vending_machine.insert_coin(coin) }

          expect(vending_machine.purchase(2))
            .to eq success_output("Item_#{attempt[:price]}", attempt[:return_coins])
        end
      end

      context 'when machine have not enough coins' do
        before do
          items << { code: 2, name: 'Cookies', quantity: 5, price: 1 }
          vending_machine.insert_coin(200)
        end

        it 'return all coins' do
          expect(vending_machine.purchase(2))
            .to eq success_output('Cookies', { 5 => 5, 2 => 3, 1 => 2 })
        end

        it 'leave in machine last inserted coin' do
          vending_machine.purchase(2)

          expect(vending_machine.coin_stack.to_h).to eq(200 => 1)
        end
      end
    end
  end

  context '#add_money' do
    it 'nil do nothing' do
      new_money = nil
      vending_machine.add_money(new_money)

      expect(vending_machine.coin_stack.to_h).to eq(money)
    end

    it 'increase quantity' do
      new_money = { 1 => 5, 5 => 5, 10 => 3, 200 => 1 }
      vending_machine.add_money(new_money)

      expect(vending_machine.coin_stack.to_h).to eq(1 => 7, 2 => 3, 5 => 10, 10 => 3, 200 => 1)
    end

    it 'invalid coins are skipped' do
      new_money = { 7 => 3, 15 => 1 }
      vending_machine.add_money(new_money)

      expect(vending_machine.coin_stack.to_h).to eq(money)
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

  context '#save_inserted_coins' do
    it 'reset @inserted_coins' do
      vending_machine.insert_coin(50)
      vending_machine.insert_coin(20)
      vending_machine.insert_coin(20)
      vending_machine.insert_coin(10)

      expect { vending_machine.purchase(1) }
        .to change { vending_machine.inserted_coins.to_h }
        .from(50 => 1, 20 => 2, 10 => 1)
        .to({})
    end
  end
end

def success_output(item_name, coins = {})
  VendingMachine.new.send(
    :display_output,
    { name: item_name },
    CoinStack.new(coins)
  )
end
