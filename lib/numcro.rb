# -*- coding: utf-8 -*-
require "active_support"
require "active_support/core_ext"
require "yaml"

class InvalidFormatError < Exception; end
class NotUniquenessError < Exception; end

class NumberCross
  attr_accessor :x, :y, :answer_length, :answer_numbers
  attr_reader   :sheet, :numbers

  def initialize
    @x = nil
    @y = nil
    @answer_length = nil
    @answer_numbers = []
    @numbers = Hash.new(0)
    @sheet = nil
  end

  def to_yaml
    yml = {size: {x: @x, y: @y}}.to_yaml
    yml+= {answer:
           {length: @answer_length,
            numbers: @answer_numbers.join(".")}}.to_yaml
    yml+= {numbers: @numbers}.to_yaml
    yml+= {question: serialize_question}.to_yaml
    yml.gsub(/---\n/, "")
  end

  def serialize_question
    @sheet.map{|y| y.join(".")}.join("\n") + "\n"
  end

  def save!(file)
    File.open(file, "w"){ |f| f.write self.to_yaml }
  end

  def save(file)
    if not File.exists? file
      File.open(file, "w") do |f|
        f.write self.to_yaml
      end
    end
  end

  def load(file)
    data = HashWithIndifferentAccess.new(YAML.load_file(file))
    self.x = data[:size][:x].to_i
    self.y = data[:size][:y].to_i
    self.answer_length = data[:answer][:length].to_i
    self.answer_numbers = data[:answer][:numbers]
    @numbers = data[:numbers] || Hash.new(0)
    parse data[:question]
  end

  def == obj
    if not obj.kind_of? self.class
      false
    else
      @answer_length == obj.answer_length and
        @answer_numbers == obj.answer_numbers and
        @sheet == obj.sheet and
        @numbers == obj.numbers and
        @x == obj.x and
        @y == obj.y
    end
  end

  def create_sheet(sym=nil)
    raise RuntimeError, "instance has zero size." if size_zero?
    if not @sheet or sym == :force
      @sheet = Array.new(@y).map{ Array.new(@x, 0) }
    end
  end

  def answer_numbers=(string)
    numbers = string.split(/\./).map(&:to_i)
    raise RuntimeError, "answer cannot contain 0." if
      numbers.include? 0
    raise RuntimeError, "index size doesn't match." if
      not numbers.size == @answer_length
    @answer_numbers = numbers
  end

  def parse(lines)
    lines.split(/\n/).each.with_index{|line,i| parse_line(i, line)}
  end

  def clear val
    @numbers.each do |k, v|
      @numbers.delete k if v == val
    end
  end

  def place(n, s)
    n = n.to_i
    if not s.size == 1
      raise RuntimeError, "#{s} must be one character."
    elsif not @sheet.flatten.include?(n)
      raise IndexError, "#{n} doesn't exist in the question."
    elsif @numbers.has_value? s
      raise NotUniquenessError, "#{s} is already registered as a member."
    elsif s == "*"
      @numbers.delete(n)
    else
      @numbers[n] = s
    end
  end

  def x=(n)
    @x = n if integer?(n)
    create_sheet if not size_zero?
  end

  def y=(n)
    @y = n if integer?(n)
    create_sheet if not size_zero?
  end

  def integer?(n)
    if not n.kind_of?(Integer)
      raise TypeError, "#{n.inspect} is not an Integer"
    elsif n <= 0
      raise RuntimeError, "#{n} is not a positive integer."
    else
      true
    end
  end

  def has_sheet?
    @sheet ? true : false
  end

  def to_s
    create_sheet
    lines = hr
    @y.times do |x|
      lines += hr(x)
    end
    lines += hr
  end

  def hr(y=nil)
    if y
      "|" + @sheet[y].inject(""){ |r, n|
        if @numbers.has_key?(n)
          r += @numbers[n] + "|"
        else
          cell = n.zero? ? "**" : sprintf("%02d", n)
          r += "#{cell}|"
        end
      } + "\n"
    else
      "+" + Array.new(@x).inject(""){|r| r+="--+"} + "\n"
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

  def parse_line(y, string)
    create_sheet
    raise IndexError, "out of index" if y >= @y
    indices = split_indices(string)
    raise IndexError, "out of index" if not indices.size == @x
    indices.each.with_index do |n, x|
      @sheet[y][x] = n
    end
  end

  def split_indices(string)
    if not string.match(/^[0-9\.]+$/)
      raise InvalidFormatError, "must contain only numbers and dots."
    end
    string.split(/\./).map(&:to_i)
  end

  def size_zero?
    @x.blank? or @y.blank? or @x.zero? or @y.zero?
  end

  private :hr, :parse_line, :create_sheet, :size_zero?, :integer?
  private :split_indices, :serialize_question
end
