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
    @numbers = Hash.new(0)
    @sheet = nil
  end

  def create_sheet
    raise RuntimeError, "instanse has zero size." if size_zero?
  end

  def to_s
    create_sheet
    lines = hr
    @y.times do
      lines += hr(true)
    end
    lines += hr
  end

  def hr(normal=false)
    if normal
      "|" + Array.new(@x).inject(""){|r,i| r+="  |"} + "\n"
    else
      "+" + Array.new(@x).inject(""){|r,i| r+="--+"} + "\n"
    end
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

  def parse_line(i, string)

  end

  def size_zero?
    @x.blank? or @y.blank? or @x.zero? or @y.zero?
  end

  private :hr, :parse_line, :create_sheet, :size_zero?
end
