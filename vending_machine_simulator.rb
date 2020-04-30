#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/vending_machine'

items = [
  { name: 'Smarties', code: 'A01', quantity: 10, price: 60 },
  { name: 'Caramac Bar', code: 'A02', quantity: 5, price: 60 },
  { name: 'Dairy Milk', code: 'A03', quantity: 1, price: 65 },
  { name: 'Freddo', code: 'A04', quantity: 1, price: 25 },
  { name: 'Crunchie', code: 'A05', quantity: 10, price: 70 },
  { name: 'Starbar', code: 'A06', quantity: 1, price: 99 },
  { name: 'Snickers', code: 'A07', quantity: 7, price: 89 },
  { name: 'Yorkie', code: 'A08', quantity: 20, price: 87 },
  { name: 'Toblerone', code: 'A09', quantity: 1, price: 199 },
  { name: 'Flake', code: 'A10', quantity: 10, price: 27 },
  { name: 'Ready Salted Crisps', code: 'B01', quantity: 7, price: 55 },
  { name: 'Sweet Chilli Crisps', code: 'B02', quantity: 12, price: 120 },
  { name: 'Smoky Barbecue Crisps', code: 'B03', quantity: 10, price: 65 },
  { name: 'Salt and Vinegar Crisps', code: 'B04', quantity: 5, price: 60 },
  { name: 'Roast Chicken Crisps', code: 'B05', quantity: 10, price: 59 },
  { name: 'Cheese and Onion Crisps', code: 'B06', quantity: 0, price: 67 },
  { name: 'Prawn Cocktail Crisps', code: 'B07', quantity: 10, price: 77 },
  { name: 'Thai Sweet Chicken Crisps', code: 'B08', quantity: 10, price: 88 },
  { name: 'Flamed Steak Crisps', code: 'B09', quantity: 10, price: 43 },
  { name: 'Coke', code: 'C02', quantity: 50, price: 75 },
  { name: 'Diet Coke', code: 'C03', quantity: 50, price: 75 },
  { name: 'Coke Zero', code: 'C04', quantity: 0, price: 75 },
  { name: 'Dandelion and Burdock', code: 'C05', quantity: 10, price: 68 },
  { name: 'Cream Soda', code: 'C06', quantity: 5, price: 69 },
  { name: 'Irn Bru', code: 'C07', quantity: 3, price: 79 },
  { name: 'Cherry Coke', code: 'C08', quantity: 1, price: 75 },
  { name: 'Orange Soda', code: 'C09', quantity: 10, price: 79 },
  { name: 'Parma Violets', code: 'D01', quantity: 10, price: 127 },
  { name: 'Refresher Chews', code: 'D02', quantity: 10, price: 427 }
]
money = {
  1 => 50,
  2 => 20,
  5 => 20,
  10 => 10,
  20 => 10,
  50 => 10,
  100 => 10,
  200 => 5
}

vending_machine = VendingMachine.new(items, money)
vending_machine.run
