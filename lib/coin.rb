# frozen_string_literal: true

class Coin
  include Comparable
  VALID_DENOMINATION = [1, 2, 5, 10, 20, 50, 100, 200].freeze

  attr_accessor :quantity
  attr_reader :denomination

  def initialize(denomination, quantity)
    @denomination = denomination
    @quantity = quantity
  end

  def self.valid?(denomination)
    VALID_DENOMINATION.include?(denomination)
  end

  def +(other)
    @quantity += other
  end

  def -(other)
    raise ArgumentError, "There is only #{self}" if quantity < other

    @quantity -= other
  end

  def <=>(other)
    return quantity <=> other if other.is_a? Integer

    denomination <=> other.denomination
  end

  def to_s
    return "#{quantity} x £#{denomination / 100}" if denomination >= 100

    "#{quantity} x #{denomination}p"
  end
end
