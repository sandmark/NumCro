# -*- coding: utf-8 -*-
require "spec_helper"
require "numcro"

describe "ナンクロ" do
  before do
    X = 10
    Y = 3
  end

  before :each do
    @numcro = NumberCross.new
    @numcro.x = X
    @numcro.y = Y
  end

  it "to_sでシートを表示" do
    expect(@numcro.to_s).to eq <<EOS
+--+--+--+--+--+--+--+--+--+--+
|  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |
+--+--+--+--+--+--+--+--+--+--+
EOS
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
