#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require "./lib/numcro.rb"

def ask_question_info
  puts
  print "横幅: "
  x = readline.chomp.to_i
  print "縦幅: "
  y = readline.chomp.to_i
  print "答えの長さ: "
  answer_length = readline.chomp.to_i

  [x,y,answer_length]
end

if $0 == __FILE__
  begin
    info = ask_question_info
    puts
    puts "サイズ: [#{info[0]}x#{info[1]}], 答え: #{info[2]}文字"
    print "これでいいですか？(Y/n)"
  end while readline.chomp == "n"

  question = NumberCross.new(*info)
end
