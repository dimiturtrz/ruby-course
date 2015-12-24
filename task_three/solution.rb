class RationalSequence
  include Enumerable

  def initialize(max_index)
    @rational_array = []
    @diagonals = 1
    @cell = 1
    @size = 0
    extend max_index unless max_index<=0
  end

  def extend(by=1)
    #reverse gauss numbers sum formula(close enough) gives us the number of diagonals
    new_diagonals = Math.sqrt(by*2).floor+2
    @diagonals.upto @diagonals+new_diagonals do |diagonal_index|
      @cell = 1 if diagonal_index-1 <= @cell
      ratio, lowering_index = diagonal_index.odd? ?
        [[@cell, diagonal_index+1], 1] : [[diagonal_index+1, @cell], 0]
      rising_index = lowering_index==0 ? 1 : 0
      @cell.upto diagonal_index do |cell_index|
        ratio[lowering_index] -= 1
        ratio[rising_index] = cell_index
        @rational_array.push(Rational(ratio[0], ratio[1]))
        @cell = cell_index
      end
    end
    @size += by
    @rational_array = @rational_array.uniq[0..(@size-1)]
    @diagonals = (@rational_array.min.denominator > @rational_array.max) ?
	    @rational_array.min.denominator : @rational_array.max.numerator
  end

  def each
    @rational_array.each{|element| yield element}
  end
end

class PrimeSequence
  include Enumerable

  def initialize(max_index)
    @prime_array = []
    @current_number = 1
    @size = 0
    extend max_index
  end

  def extend(by=1)
    @size += by
    while @prime_array.size < @size
      @current_number += (@current_number<3)? 1 : 2 # all prime numbers after 3 are odd
      @prime_array.push(@current_number) if prime?(@current_number)
    end
  end

  def prime?(number)
    return false if number == 1
    square_root = Math.sqrt number
    denominators = @prime_array.take_while{ |element| element <= square_root }
    return true if denominators.size == 0
    denominators.each { |element| return false if number % element == 0 }
    true
  end

  def each
    @prime_array.each{|element| yield element}
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(max_index, first: 1, second: 1)
    @fibonacci_array = [first, second]
    @size = max_index
    @first, @second = first, second
    extend(max_index)
    @fibonacci_array = @fibonacci_array[0..(max_index-1)]
    @first, @second = @fibonacci_array[-2], @fibonacci_array[-1]
  end

  def extend(by=1)
    @size += by
    while @fibonacci_array.size < @size
      @first, @second = @second, @first + @second
      @fibonacci_array.push @second
    end
  end

  def each
    @fibonacci_array.each{|element| yield element}
  end
end

module DrunkenMathematician
  module_function

  def meaningless(n)
    rational_sequence = RationalSequence.new(n).to_a
    prime_sequence = PrimeSequence.new(Math.sqrt(2*n).floor + 1)
    numerator, denominator = 1, 1
    rational_sequence.each do |rational_number|
      if prime_sequence.prime?(rational_number.numerator) ||
        prime_sequence.prime?(rational_number.denominator)
        numerator *= rational_number
      else denominator *= rational_number
      end
    end
    numerator/denominator
  end

  def aimless(n)
    prime_sequence = PrimeSequence.new(n).to_a
    sum = prime_sequence.size.even? ? 0 : prime_sequence.pop
    prime_sequence.each_slice(2){ |first, second| sum+=Rational(first,second) }
    sum
  end

  def worthless(n)
    limit = FibonacciSequence.new(n).to_a.last
    rational_sequence = RationalSequence.new(1)
    rational_sequence.extend while rational_sequence.to_a.inject(:+)<=limit
    rational_sequence.to_a[0..-2]
  end
end
