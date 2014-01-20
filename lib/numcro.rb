# -*- coding: utf-8 -*-
require "active_support"
require "active_support/core_ext"

class NumberCross
  attr_accessor :x, :y, :answer_length, :answer_numbers

  def initialize
    @x = nil
    @y = nil
    @answer_length = nil
    @answer_numbers = []
    @numbers = {}
  end

  def []= n, s
    @numbers[n] = s
  end

  def answer
    @answer_numbers.map{|n|
      if @numbers.has_key? n
        @numbers[n]
      else
        sprintf("%02d", n)
      end
  }.join("|")
  end
end
