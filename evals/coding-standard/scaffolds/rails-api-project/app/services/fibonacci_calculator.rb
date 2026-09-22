class FibonacciCalculator
  def compute(n)
    return n if n <= 1

    a = 0
    b = 1
    (n - 1).times do
      a, b = b, a + b
    end

    b
  end
end
