# -*- coding: utf-8 -*-
require "spec_helper"
require "numcro"

describe "ナンクロ" do
  before :each do
    @numcro = NumberCross.new
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
