#!/usr/bin/env ruby

class Prime
  def initialize(n)
    @number = n
  end

  def prime?
    return false if @number <= 1
    return true if @number == 2

    (2..Math.sqrt(@number)).each do |i|
      return false if (@number % i).zero?
    end
    true
  end
end

def prime(number)
  prime_instance = Prime.new(number)
  prime_instance.prime?
end
