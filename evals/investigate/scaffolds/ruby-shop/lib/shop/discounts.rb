module Shop
  module Discounts
    # Takes a percentage off the running total.
    class Percentage
      def initialize(percent)
        @percent = percent
      end

      def amount_off_cents(_cart, running_total_cents)
        (running_total_cents * @percent / 100.0).round
      end
    end

    # Takes a percentage off the running total once the cart reaches a minimum subtotal.
    # Duplicates Percentage's arithmetic rather than reusing it.
    class Threshold
      def initialize(percent, minimum_subtotal_cents)
        @percent = percent
        @minimum_subtotal_cents = minimum_subtotal_cents
      end

      def amount_off_cents(cart, running_total_cents)
        return 0 if cart.subtotal_cents < @minimum_subtotal_cents

        (running_total_cents * @percent / 100.0).round
      end
    end
  end
end
