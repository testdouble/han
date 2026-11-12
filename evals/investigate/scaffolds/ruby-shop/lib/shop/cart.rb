require_relative "pricing"

module Shop
  # A cart holds line items and asks Pricing for its total.
  class Cart
    LineItem = Struct.new(:sku, :unit_price_cents, :quantity)

    attr_reader :items, :discounts

    def initialize(discounts: [])
      @items = []
      @discounts = discounts
    end

    def add(sku, unit_price_cents, quantity = 1)
      items << LineItem.new(sku, unit_price_cents, quantity)
      self
    end

    def subtotal_cents
      items.sum { |item| item.unit_price_cents * item.quantity }
    end

    def total_cents
      Pricing.new(discounts).total_cents(self)
    end
  end
end
