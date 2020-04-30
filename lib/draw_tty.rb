# frozen_string_literal: true

require 'tty-box'
require 'tty-screen'

module DrawTTY
  COLUMN_SIZE = 4
  WIDTH_SIDE_COLUMN = TTY::Screen.width / COLUMN_SIZE - 2
  WIDTH_CENTRAL_COLUMN = TTY::Screen.width / 2 - 2

  FROM_LEFT_LEFT_COLUMN = 2
  FROM_LEFT_RIGHT_COLUMN = (COLUMN_SIZE - 1) * WIDTH_SIDE_COLUMN + COLUMN_SIZE + 2
  FROM_LEFT_CENTRAL_COLUMN = TTY::Screen.width / 4 + 1

  COIN_STACK_HEIGHT = TTY::Screen.height / 10

  def main_box(&block)
    print TTY::Box.frame(
      '',
      title: { top_center: ' Vending Machine ' },
      border: :thick,
      width: TTY::Screen.width,
      height: TTY::Screen.height - 1,
      style: {
        fg: :bright_yellow,
        bg: :blue,
        border: {
          fg: :bright_yellow,
          bg: :blue
        }
      }
    )
    money_box
    coin_stack_box
    items_box
    output_box(&block)
    inserted_coins_counter_box
    inserted_coins_box
  end

  def money_box
    print TTY::Box.frame(
      "£#{coin_stack.sum.to_f / 100}",
      title: {
        top_center: ' Coin Stack '
      },
      top: 2,
      left: FROM_LEFT_LEFT_COLUMN,
      width: WIDTH_SIDE_COLUMN,
      height: [COIN_STACK_HEIGHT, 4].max,
      border: :thick,
      align: :center,
      padding: 1,
      style: {
        bg: :black,
        fg: :magenta,
        border: {
          fg: :green,
          bg: :black
        }
      }
    )
  end

  def coin_stack_box
    Coin::VALID_DENOMINATION.each_with_index do |denomination, i|
      print TTY::Box.frame(
        ('*' * (coin_stack[denomination]&.quantity || 0)).to_s,
        title: {
          top_center: " #{coin_stack[denomination]} "
        },
        top: i * COIN_STACK_HEIGHT + 2 * COIN_STACK_HEIGHT,
        left: FROM_LEFT_LEFT_COLUMN,
        width: WIDTH_SIDE_COLUMN,
        height: COIN_STACK_HEIGHT,
        border: :thick,
        align: :left,
        style: {
          bg: :black,
          fg: :magenta,
          border: {
            fg: :green,
            bg: :black
          }
        }
      )
    end
  end

  def items_box
    print TTY::Box.frame(
      items_display.to_s,
      title: {
        top_center: ' Items '
      },
      top: 2,
      left: FROM_LEFT_CENTRAL_COLUMN,
      width: WIDTH_CENTRAL_COLUMN,
      height: TTY::Screen.height - 11,
      border: :thick,
      align: :left,
      padding: 1,
      style: {
        bg: :black,
        fg: :yellow,
        border: {
          fg: :green,
          bg: :black
        }
      }
    )
  end

  def output_box
    text = [
      'i = Insert Coin :: b = Buy Item :: q = Quit'
    ]

    text << '' << yield if block_given?

    print TTY::Box.frame(
      text.join("\n"),
      title: {
        top_center: ' Output '
      },
      top: TTY::Screen.height - 9,
      left: FROM_LEFT_CENTRAL_COLUMN,
      width: WIDTH_CENTRAL_COLUMN,
      height: 7,
      border: :thick,
      align: :center,
      padding: 1,
      style: {
        bg: :black,
        fg: :magenta,
        border: {
          fg: :green,
          bg: :black
        }
      }
    )
  end

  def inserted_coins_counter_box
    print TTY::Box.frame(
      "£#{inserted_coins.sum.to_f / 100}",
      title: {
        top_center: ' Inserted '
      },
      top: 2,
      left: FROM_LEFT_RIGHT_COLUMN,
      width: WIDTH_SIDE_COLUMN,
      height: [COIN_STACK_HEIGHT, 4].max,
      border: :thick,
      align: :center,
      padding: 1,
      style: {
        bg: :black,
        fg: :magenta,
        border: {
          fg: :green,
          bg: :black
        }
      }
    )
  end

  def inserted_coins_box
    Coin::VALID_DENOMINATION.each_with_index do |denomination, i|
      print TTY::Box.frame(
        ('*' * (inserted_coins[denomination]&.quantity || 0)).to_s,
        title: {
          top_center: " Coin £#{denomination.to_f / 100} "
        },
        top: i * COIN_STACK_HEIGHT + 2 * COIN_STACK_HEIGHT,
        left: FROM_LEFT_RIGHT_COLUMN,
        width: WIDTH_SIDE_COLUMN,
        height: COIN_STACK_HEIGHT,
        border: :thick,
        align: :left,
        style: {
          bg: :black,
          fg: :magenta,
          border: {
            fg: :green,
            bg: :black
          }
        }
      )
    end
  end

  def handle_output_message(output)
    return flash_box(output.to_s, :warn) if output.is_a? ArgumentError
    return flash_box(output.to_s, :error) if output.is_a? RangeError

    flash_box(output)
  end

  FLASH_BOX_WIDTH = 40
  FLASH_BOX_HEIGHT = 6

  def flash_box(message, mth = :success)
    print TTY::Box.send(
      mth,
      message,
      {
        top: TTY::Screen.height / 2 - FLASH_BOX_HEIGHT / 2,
        left: TTY::Screen.width / 2 - FLASH_BOX_WIDTH / 2,
        align: :center,
        width: FLASH_BOX_WIDTH,
        height: FLASH_BOX_HEIGHT
      }
    )
  end
end
