# VendingMachine

#### All money/coins denomination as integers (100 = £1, 1 = 1p)

1. Money and Items are ideal candidates for OpenStruct, but i didn't want to over engineer.
2. I assume that heart of Vending Machine is how coins are counted and returned and that is a place where i was focused.
3. In cases where sum of inserted coins is bigger then item price VendingMachine always try to return money:
Coke cost 100(£1), Customer insert 200(£2)
  - Ideal scenario: VendingMachine got 100p in stock => Customer will purchase Coke and get 100p change.
  - Good  scenario: VendingMachine got 99p in stock => Customer will purchase Coke and get 99p change.
  - Worst scenario: VendingMachine got 1p in stock => Customer will purchase Coke and get 1p change.
Setting THRESHOLD will be good idea.

### Initialize

```ruby
  money = { 1 => 2, 2 => 3, 5 => 5 }
  items = [
    { code: 1, name: 'Snacks', quantity: 5, price: 130 }
  ]

  vending_machine = VendingMachine.new(items, money)

  vending_machine.insert_coin(100)
  vending_machine.insert_coin(3) => 'Coin invalid'
  vending_machine.insert_coin(20)
  vending_machine.insert_coin(20)

  vending_machine.purchase(1) => "Please take your: Snacks and 2 of 5p as change."
```

### Add new items
##### List of Hashes
If VendingMachine already contain item it will increase quantity
else add item to list.
```ruby
items = [{ code: 1, name: 'Snikers', quantity: 5, price: 99 }]

vending_machine.add_items(items)
```

### Add money
##### Hash where
 - key = denomination
 - value = quantity
```ruby
# old syntax because key is integer
money = { 1 => 11, 2 => 22, 5 => 55, 10 => 111, 20 => 222, 50 => 555, 100 => 1111, 200 => 2222 }

vending_machine.add_money(money)
```

## Test
`bin/rspec spec/ --format doc`
