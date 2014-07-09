require "rspec"
require "demo_expressions/parser"

module DemoExpressions

  describe Parser do

    # 1. lexer; parsing(str), next_token, parse_error
    # 2. arithmetic tokens lexer (with tests)

    it "extracts tokens from an arithmetic expression" do
      str = "((55.92 - 66.74) * 12.87)"
      parser = Parser.new
      parser.parsing(str)
      parser.next_token.type.should eq(:T_LPAR)
      parser.next_token.type.should eq(:T_LPAR)
      parser.next_token.should eq(Token.new(:T_FLOAT, 55.92))
      parser.next_token.type.should eq(:T_MINUS)
      parser.next_token.should eq(Token.new(:T_FLOAT, 66.74))
      parser.next_token.type.should eq(:T_RPAR)
      parser.next_token.type.should eq(:T_TIMES)
      parser.next_token.should eq(Token.new(:T_FLOAT, 12.87))
      parser.next_token.type.should eq(:T_RPAR)
      parser.next_token.should be_nil
    end

    it "raises parse error if it can't be lexed" do
      str = "1 + two & three"
      parser = Parser.new
      parser.parsing(str)
      parser.next_token.type.should eq(:T_INT)
      parser.next_token.type.should eq(:T_PLUS)
      expect {
        parser.next_token
      }.to raise_error(ParsingTools::ParseError, 'unknown token - "two"')
    end

    # 3. lookahead: lookahead, lookahead(k), shift_token

    it "can lookahead at the next token" do
      parser = Parser.new("1 + 2 * 3")
      parser.lookahead.type.should eq(:T_INT)
      parser.lookahead.value.should eq(1)
      parser.shift_token.value.should eq(1)
      parser.lookahead.type.should eq(:T_PLUS)
      parser.lookahead.value.should eq("+")
      parser.shift_token.type.should eq(:T_PLUS)
    end

    it "can lookahead at several tokens" do
      parser = Parser.new("1 + 2.3 * 4")
      t0, t1, t2, t3 = parser.lookahead(3)
      t0.should eq(Token.new(:T_INT, 1))
      t1.should eq(Token.new(:T_PLUS, "+"))
      t2.should eq(Token.new(:T_FLOAT, 2.3))
      t3.should be_nil
      t0, t1, t2, t3 = parser.lookahead(2)
      t0.should eq(Token.new(:T_INT, 1))
      t1.should eq(Token.new(:T_PLUS, "+"))
      t2.should be_nil
      t3.should be_nil
      parser.shift_token
      parser.lookahead.should eq(Token.new(:T_PLUS, "+"))
      parser.shift_token
      parser.lookahead.should eq(Token.new(:T_FLOAT, 2.3))
      parser.shift_token
      t0, t1, t2, t3 = parser.lookahead(4)
      t0.should eq(Token.new(:T_TIMES, "*"))
      t1.should eq(Token.new(:T_INT, 4))
      t2.should be_nil
      t3.should be_nil
    end

    # 4. lookahead convenience helpers: match, accept, lookahead?(t1, t2, t3)

    it "has a convenient accept (and shift) method" do
      parser = Parser.new("(1   /  2) * 2")
      parser.accept(:T_MINUS, :T_INT, :T_FLOAT).should be_nil
      parser.accept(:T_LPAR, :T_INT, :T_FLOAT).should eq(Token.new(:T_LPAR, "("))
      parser.accept(:T_LPAR, :T_INT, :T_FLOAT).should eq(Token.new(:T_INT, 1))
    end

    it "has a convenient match (and shift, or die) method" do
      parser = Parser.new("1 + 2.3 * 4")
      token = parser.match(:T_INT, :T_FLOAT)
      # parser position has automatically advanced
      token.value.should eq(1)
      expect {
        parser.match(:T_LPAR, :T_FLOAT)
      }.to raise_error(
        ParsingTools::ParseError,
        "unexpected token T_PLUS (expected T_LPAR or T_FLOAT)"
      )
    end

    it "has a convenient lookahead multiple tokens accept method" do
      parser = Parser.new("((4/3))")
      parser.lookahead?(:T_LPAR, :T_INT, :T_RPAR).should be_false
      parser.lookahead?(
        :T_LPAR, [:T_INT, :T_LPAR], [:T_INT, :T_FLOAT]
      ).should be_true
      # check the EOF condition
      parser.shift_token # (
      parser.shift_token # (
      parser.shift_token # 4
      parser.shift_token # /
      parser.shift_token # 3
      parser.lookahead?(:T_RPAR, :T_RPAR, :T_RPAR).should be_false
      parser.lookahead?(:T_RPAR, :T_RPAR, nil).should be_true
    end

    # 5. arithmetic expression grammar: parse(str)

    describe "parsing expressions" do

      it "parses '1'" do
        ptree = Parser.new.parse("1")
        ptree.should be_number
        ptree.should_not be_operation
        ptree.value.should eq(1)
        ptree.evaluate.should eq(1)
      end

      it "parses '0 - 4.3 + 0.23'" do
        ptree = Parser.new.parse("0 - 4.3 + 0.23")
        ptree.evaluate.should be_within(0.0001).of(-4.07)
      end

      it "parses '1+  2'" do
        ptree = Parser.new.parse("1+  2")
        ptree.should_not be_number
        ptree.should be_operation
        ptree.value.should eq("(1 + 2)")
        ptree.lval.value.should eq(1)
        ptree.rval.value.should eq(2)
        ptree.evaluate.should eq(3)
      end

      it "parses '30.0/4/5/6'" do
        ptree = Parser.new.parse("30.0/4/5/6")
        ptree.value.should eq("(((30.0 / 4) / 5) / 6)")
        ptree.evaluate.should be_within(0.00001).of(0.25)
      end

      it "parses a big complicated expression" do
        str = "((55.91 - 66.73) * 12.87 + 47.22)/((33.2 + 44) + 9)/2*(500/2/3/(4+9))"
        ptree = Parser.new(str).parse
        ptree.evaluate.should be_within(0.00001).of(-3.20301856)
      end

    end

  end

end

