class FibonacciController < ApplicationController
  def calculate
    n = params[:n]
    calculator = FibonacciCalculator.new
    number = calculator.compute(n.to_i)

    render json: { value: number }
  end
end
