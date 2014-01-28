# -*- coding: utf-8 -*-
require "spec_helper"
require "numcro"

describe "ナンクロ" do
  before :all do
    X = 5
    Y = 3
    OUT_OF_INDEX = 3
    InvalidSeq = "1.2.3.4.a.b.c"
    QUESTION_TO_15 = <<EOS
1.2.3.4.5
6.7.8.9.10
11.12.13.14.15
EOS
    ONE_TO_FIVE = <<EOS
+--+--+--+--+--+
|01|02|03|04|05|
|01|02|03|04|05|
|01|02|03|04|05|
+--+--+--+--+--+
EOS
    ONE_ALL = <<EOS
+--+--+--+--+--+
|01|01|01|01|01|
|01|01|01|01|01|
|01|01|01|01|01|
+--+--+--+--+--+
EOS
    BLANK_SHEET = <<EOS
+--+--+--+--+--+
|**|**|**|**|**|
|**|**|**|**|**|
|**|**|**|**|**|
+--+--+--+--+--+
EOS
  end

  before :each do
    @numcro = NumberCross.new
    @zero   = NumberCross.new
    @numcro.x = X
    @numcro.y = Y
  end

  describe "save" do
    before :all do
      FILE = current_dir("output.yml")
      SAVE_X = 5
      SAVE_Y = 3
      ANS_LEN = 5
      ANS_NUM = "1.2.3.4.5"
      SAVE_NUMBERS = {1=>"1", 2=>"2" ,3=>"3"}
    end

    before :each do
      @numcro = NumberCross.new
      @numcro.x = SAVE_X
      @numcro.y = SAVE_Y
      @numcro.answer_length = ANS_LEN
      @numcro.answer_numbers = ANS_NUM
      @numcro.parse QUESTION_TO_15
      SAVE_NUMBERS.each do |number, char|
        @numcro.place number, char
      end
    end

    after :each do
      if File.exists? FILE
        FileUtils.rm FILE
      end
    end


    describe "serialize_question" do
      it "@sheetを文字列に変換する" do
        expect(@numcro.send(:serialize_question)).
          to eq QUESTION_TO_15
      end
    end

    it "answer_numbersを文字列で保存する" do
      @numcro.save FILE
      data = YAML.load_file FILE
      expect(data[:answer][:numbers]).to be_kind_of(String)
    end

    it "問題を保存する" do
      @numcro.save FILE
      data = YAML.load_file FILE
      expect(data.has_key? :question).to be_true
    end

    it "数値と文字の対(numbers)を保存する" do
      @numcro.save FILE
      data = YAML.load_file FILE
      expect(data.has_key? :numbers).to be_true
      expect(data[:numbers].size).to eq SAVE_NUMBERS.size
      data[:numbers].each do |number|
        expect(SAVE_NUMBERS[number]).to eq SAVE_NUMBERS[number]
      end
    end

    it "load で読み込める" do
      @numcro.save FILE
      @loaded = NumberCross.new
      @loaded.load FILE
      expect(@numcro == @loaded).to be_true
    end

    it "ファイルは上書きしない" do
      file = current_dir("test.yml")
      File.open(file, "w"){ |f| f.write ""}
      @numcro.save(file)
      expect(File.read(file)).to be_blank
      FileUtils.rm(file)
    end

    it "指定されたファイルに保存する" do
      @numcro.save(FILE)
      expect(File.exists?(FILE)).to be_true
      FileUtils.rm FILE
    end
  end

  describe "load" do
    before :all do
      LOAD_X = X
      LOAD_Y = Y
      YML = "sample.yml"
      YML_QUESTION = <<EOS
+--+--+--+--+--+
|01|02|03|04|05|
|06|07|08|09|10|
|11|12|13|14|15|
+--+--+--+--+--+
EOS
    end

    before :each do
      @numcro = NumberCross.new
      @numcro.load YML
    end

    it "サイズを取得する" do
      expect{@numcro.load(YML)}.to_not raise_error
      expect(@numcro.x).to eq LOAD_X
      expect(@numcro.y).to eq LOAD_Y
    end

    it "答えの情報を取得する" do
      expect(@numcro.answer_length).to eq 5
      expect(@numcro.answer_numbers).to eq [1,2,3,4,5]
    end

    it "問題を取得する" do
      expect(@numcro.to_s).to eq YML_QUESTION
    end
  end

  describe "integer?" do
    it "数値以外の場合例外を投げる" do
      expect{@zero.send(:integer?, :a)}.to raise_error(TypeError)
    end

    it "整数の場合は真を返す" do
      expect(@zero.send(:integer?, 1)).to be_true
    end

    it "負の整数の場合は例外を投げる" do
      expect{@zero.send(:integer?, -1)}.to raise_error
    end

    it "Float型は受け付けない" do
      expect{@zero.send(:integer?, 1.0)}.to raise_error(TypeError)
    end
  end

  describe "サイズ" do
    it "xは数値以外受け付けない" do
      expect{@zero.x=:a}.to raise_error(TypeError)
    end

    it "yは数値以外受け付けない" do
      expect{@zero.y=:a}.to raise_error(TypeError)
    end
  end

  describe "例外" do
    before :each do
      @enumcro = NumberCross.new
    end

    describe "size_zero?" do
      it "xがnilの場合真を返す" do
        @enumcro.y = 1
        expect(@enumcro.send(:size_zero?)).to be_true
      end

      it "yがnilの場合真を返す" do
        @enumcro.x = 1
        expect(@enumcro.send(:size_zero?)).to be_true
      end

      it "x,yともにnilの場合真を返す" do
        expect(@enumcro.send(:size_zero?)).to be_true
      end
    end

    it "サイズ nil でシートは作れない" do
      expect{@enumcro.send(:create_sheet)}
        .to raise_error(RuntimeError)
    end

    it "サイズ nil を to_s" do
      expect{@enumcro.to_s}.to raise_error(RuntimeError)
    end

    it "size_zero? が真のとき parse_line は例外を投げる" do
      expect{@enumcro.send(:parse_line, 0, "1.2.3.4.5")}
        .to raise_error(RuntimeError)
    end
  end

  describe "シート" do
    before :each do
      @sheet = @numcro.instance_eval("@sheet")
      @numbers = @numcro.instance_eval("@numbers")
    end

    describe "create_sheet" do
      it "シートが存在する場合は何もしない" do
        @numcro.parse("1.2.3.4.5\n"*3)
        expect(@numcro.instance_eval("@sheet")).to be_kind_of(Array)
        @numcro.to_s
        expect(@numcro.to_s).to eq ONE_TO_FIVE
      end

      it ":forceが指定された場合上書きする" do
        @numcro.parse("1.1.1.1.1\n"*3)
        expect(@numcro.to_s).to eq ONE_ALL
        @numcro.send(:create_sheet, :force)
        expect(@numcro.to_s).to eq BLANK_SHEET
      end
    end

    describe "place" do
      before :each do
        @numcro.parse QUESTION_TO_15
      end

      it "数字に文字を関連付ける" do
        @numcro.place(1, "あ")
        expect(@numbers[1]).to eq "あ"
      end

      it "to_sに反映される" do
        @numcro.place(14, "あ")
        expect(@numcro.to_s).to eq <<EOS
+--+--+--+--+--+
|01|02|03|04|05|
|06|07|08|09|10|
|11|12|13|あ|15|
+--+--+--+--+--+
EOS
      end

      it "数値はparse_lineで入力された範囲内でなければならない" do
        expect{@numcro.place(1, "あ")}.to_not raise_error
        expect{@numcro.place(16,"あ")}.to raise_error(IndexError)
      end

      it "文字は一文字でなければならない" do
        expect{@numcro.place(1,"あい")}.to raise_error
        expect{@numcro.place(1,"")}.to raise_error
      end
    end

    it "x,yが指定された時点でシートを作る" do
      expect(@numcro.has_sheet?).to be_true
    end

    it "Integerの二次元配列" do
      expect(@sheet).to be_kind_of(Array)
      @sheet.each do |line|
        expect(line).to be_kind_of(Array)
        line.each do |cell|
          expect(cell).to be_kind_of(Integer)
        end
      end
    end

    it "一次配列はY個の要素を持つ" do
      expect(@sheet.size).to eq Y
    end

    it "二次配列はX個の要素を持つ" do
      @sheet.each do |line|
        expect(line.size).to eq X
      end
    end

    describe "parse_line" do
      it "複数行はparseがまとめて処理する" do
        @another = NumberCross.new
        @another.x = X
        @another.y = Y
        @numcro.y.times do |i|
          @numcro.send(:parse_line, i, "1.2.3.4.5")
        end
        @another.parse("1.2.3.4.5\n"*3)
        expect(@another.to_s).to eq @numcro.to_s
        expect(@another.to_s).to eq ONE_TO_FIVE
      end

      it "行末に改行文字が含まれている場合は無視する" do
        expect{@numcro.send(:parse_line, 0, "1.2.3.4.5\n")}.
          to_not raise_error
        sheet = @numcro.instance_eval("@sheet")
        expect(sheet[0][0]).to eq 1
      end

      it "範囲外のインデックスを渡されたとき例外を投げる" do
        expect{
          @numcro.send(:parse_line, OUT_OF_INDEX, "1.2.3.4.5")
        }.to raise_error(IndexError)
      end

      it "文字列がインデックスの範囲外だった場合例外を投げる" do
        expect {
          @numcro.send(:parse_line, 0, "1.2.3.4.5.10")
        }.to raise_error(IndexError)

        expect {
          @numcro.send(:parse_line, 0, "1")
        }.to raise_error(IndexError)
      end

      it "数字とドット以外の文字が含まれている場合例外を投げる" do
        expect{@numcro.send(:split_indices, "1.2.3")}.
          to_not raise_error

        expect{@numcro.send(:split_indices, InvalidSeq)}.
          to raise_error(InvalidFormatError)
      end

      it "負の整数が渡された場合例外を投げる" do
        expect{@numcro.send(:split_indices, "1.2.-3.4")}.
          to raise_error(InvalidFormatError)
      end

      it "一行ずつパース" do
        @numcro.send(:parse_line, 0, "10.1.2.0.4")
        expect(@numcro.send(:hr, 0)).to eq <<EOS
|10|01|02|**|04|
EOS
      end
    end
  end

  describe "to_s" do
    it "シートを表示" do
      expect(@numcro.to_s).to eq BLANK_SHEET
    end
  end

  describe "答え" do
    before :each do
      @numcro.answer_length = 5
      @numcro.answer_numbers = "1.2.3.4.5"
    end

    describe "answer_numbers" do
      before :each do
        @numcro = NumberCross.new
        @numcro.answer_length = 5
      end

      it "長さと一致しなければ例外を投げる" do
        expect{@numcro.answer_numbers="1.2.3"}
          .to raise_error(RuntimeError)
        expect{@numcro.answer_numbers="1.2.3.4.5.6"}
          .to raise_error(RuntimeError)
      end

      it "0 は入力されない" do
        expect{@numcro.answer_numbers="1.0.2"}.
          to raise_error(RuntimeError)
      end

      it "@answer_numbersをセットする" do
        @numcro.answer_numbers="1.2.3.4.5"
        expect(@numcro.answer_numbers).to eq [1,2,3,4,5]
      end
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
