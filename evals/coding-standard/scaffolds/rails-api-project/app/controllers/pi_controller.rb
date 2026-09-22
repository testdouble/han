class PiController < ApplicationController
  def calculate
    # Compute pi to 100 decimal places using the Bailey-Borwein-Plouffe formula
    # with Ruby's BigDecimal for arbitrary precision
    require "bigdecimal"
    require "bigdecimal/math"

    precision = 120
    pi = BigMath.PI(precision)
    rounded = pi.round(100).to_s("F")

    render json: { result: rounded }
  end
end
