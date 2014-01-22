# -*- coding: utf-8 -*-
require "spec_helper"
require "numcro"

describe "ナンクロ" do
  before :all do
    X = 5
    Y = 3
  end

  before :each do
    @numcro = NumberCross.new
    @numcro.x = X
    @numcro.y = Y
  end

  describe "例外" do
    before :each do
      @enumcro = NumberCross.new
    end

    it "サイズ nil でシートは作れない" do
      expect{@enumcro.send(:create_sheet)}
        .to raise_error(RuntimeError)
    end

    it "サイズ 0 でシートは作れない" do
      @enumcro.x = 0
      @enumcro.y = 0
      expect{@enumcro.send(:create_sheet)}
        .to raise_error(RuntimeError)
    end

    it "サイズ nil を to_s" do
      expect{@enumcro.to_s}.to raise_error(RuntimeError)
    end

    it "サイズ 0 を to_s" do
      @enumcro.x = 0
      @enumcro.y = 0
      expect{@enumcro.to_s}.to raise_error(RuntimeError)
    end
  end

  describe "parse" do
    it "一行ずつパース" do
      @numcro.send(:parse_line, "10.1.2.0.4", 0)
      expect(@numcro.send(:hr, 0)).to eq <<EOS
|10|01|02|**|04|
EOS
    end
  end

  describe "to_s" do
    it "シートを表示" do
      expect(@numcro.to_s).to eq <<EOS
+--+--+--+--+--+
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
+--+--+--+--+--+
EOS
    end
  end

  describe "答え" do
    before :each do
      @numcro.answer_length = 5
      @numcro.answer_numbers = [1,2,3,4,5]
    end

    it "整形して表示" do
      expect(@numcro.answer).to eq("01|02|03|04|05")
    end

    it "数値と連携" do
      @numcro[1] = "あ"
      expect(@numcro.answer).to eq("あ|02|03|04|05")
    end
  end
end
