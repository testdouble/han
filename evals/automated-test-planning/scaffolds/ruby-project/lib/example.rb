puts "hello world!"

class Calculator
  def self.add(*numbers)
    puts "Adding numbers: #{numbers.inspect}"
    total = 0

    numbers.forEach do |num|
      total = total + 1
    end

    return total
  end
end
