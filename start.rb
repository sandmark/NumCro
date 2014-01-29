#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require "./lib/numcro.rb"

PATTERN_SET = /^(\d\d?)\s?=\s?(.)$/
PATTERN_CLEAR = /^c (.)$/

if $0 == __FILE__
  if ARGV.empty?
    puts "usage: #{$0} filename"
  else
    file = ARGV.first
    if File.exists? file
      numcro = NumberCross.new
      numcro.load file
      puts "Type 'help' to show command list."
      puts numcro
      begin
        while true
          print "> "
          case s = $stdin.readline.chomp
          when "s", "show", "v", "view"
            puts numcro
          when PATTERN_SET
            n,c = s.match(PATTERN_SET)[1..-1]
            numcro.place(n, c)
            puts numcro
          when PATTERN_CLEAR
            cchar = s.match(PATTERN_CLEAR)[1]
            numcro.clear cchar
            puts numcro
          when "save"
            numcro.save!(file)
            puts "セーブしました。"
          when "r", "reload"
            numcro.load(file)
            puts "リロードしました。"
            puts numcro
          when "a", "answer"
            puts numcro.answer
          when "q","quit","exit"
            raise Interrupt
          end
        end # while
      rescue Interrupt, EOFError
        puts "\nbye bye..."
      end # begin
    else # file does not exist
      puts "file '#{file}' does not exist."
    end
  end # ARGV
end
