# frozen_string_literal: true

require './lib/coin_stack'

RSpec.describe CoinStack do
  let(:coin_stack) { CoinStack.new }

  context '#add' do
    context 'when invalid coin' do
      it "nil raise ArgumentError, 'Coin invalid'" do
        expect { coin_stack.add(nil) }.to raise_error(ArgumentError, 'Coin invalid')
      end

      it "bad denomination raise ArgumentError, 'Coin invalid'" do
        expect { coin_stack.add('bad_coin') }.to raise_error(ArgumentError, 'Coin invalid')
      end
    end

    context 'when valid coin' do
      context 'with invalid quantity' do
        it "negative number raise ArgumentError 'Quantity must be positive'" do
          expect { coin_stack.add(1, -1) }.to raise_error(ArgumentError, 'Quantity must be positive')
        end
      end

      context 'with valid quantity' do
        context 'default 1' do
          let!(:result) { coin_stack.add(1) }

          it "return 'Coin added'" do
            expect(result).to eq 'Coin added'
          end

          it 'save a coin on stack' do
            expect(coin_stack.to_h).to eq({ 1 => 1 })
          end
        end

        context '5' do
          let!(:result) { coin_stack.add(1, 5) }

          it "return 'Coin added'" do
            expect(result).to eq 'Coin added'
          end

          it 'save a coin on stack' do
            expect(coin_stack.to_h).to eq({ 1 => 5 })
          end
        end
      end
    end
  end

  context '#get_return return correct amount and denomination of coins' do
    attempts = [
      {
        change: 9,
        stack_coins: { 10 => 1, 1 => 10 },
        return_coins: { 1 => 9 }
      },
      {
        change: 10,
        stack_coins: { 5 => 2 },
        return_coins: { 5 => 2 }
      },
      {
        change: 13,
        stack_coins: { 5 => 3, 2 => 10, 1 => 5 },
        return_coins: { 5 => 2, 2 => 1, 1 => 1 }
      },
      {
        change: 120,
        stack_coins: { 100 => 5, 50 => 5, 20 => 5, 10 => 5 },
        return_coins: { 100 => 1, 20 => 1 }
      },
      {
        change: 135,
        stack_coins: { 20 => 10, 10 => 5, 5 => 5 },
        return_coins: { 20 => 6, 10 => 1, 5 => 1 }
      },
      {
        change: 219,
        stack_coins: { 200 => 2, 5 => 10, 2 => 1, 1 => 5 },
        return_coins: { 200 => 1, 5 => 3, 2 => 1, 1 => 2 }
      },
      {
        change: 236,
        stack_coins: { 200 => 2, 5 => 11, 2 => 5, 1 => 5 },
        return_coins: { 200 => 1, 5 => 7, 1 => 1 }
      }
    ]

    attempts.each do |attempt|
      it "for change #{attempt[:change]}" do
        coin_stack = CoinStack.new(attempt[:stack_coins])

        expect(coin_stack.get_return(attempt[:change]).to_h)
          .to eq(attempt[:return_coins])
      end
    end

    context 'when coin stock have not enough coins' do
      let(:coin_stack) { CoinStack.new(200 => 1, 100 => 1, 5 => 5, 2 => 3, 1 => 2) }
      before do
        @result = coin_stack.get_return(99)
      end

      it 'return all coins smaller then change' do
        expect(@result.to_h).to eq({ 5 => 5, 2 => 3, 1 => 2 })
      end

      it 'leave in machine coins bigger then change' do
        expect(coin_stack.to_h).to eq(200 => 1, 100 => 1)
      end
    end
  end
end
