module Shop
  # Pricing applies each discount in order, then floors the total at zero.
  class Pricing
    def initialize(discounts)
      @discounts = discounts
    end

    def total_cents(cart)
      total = cart.subtotal_cents
      @discounts.each { |discount| total -= discount.amount_off_cents(cart, total) }
      [total, 0].max
    end
  end
end
