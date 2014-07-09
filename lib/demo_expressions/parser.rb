require "parsing_tools/error_handling"
require "parsing_tools/lexer"
require "parsing_tools/lookahead"
require "demo_expressions/tokens_and_nodes"

module DemoExpressions

  class Parser
    include ParsingTools::ErrorHandling
    include ParsingTools::Lexer
    include ParsingTools::Lookahead
    attr_accessor :debug

    def initialize(str=nil)
      parsing(str)
    end

    def parse(str=@str)
      parsing(str)
      expr = expression
      next_token.nil? or raise_error("Expected end of string")
      expr
    end

    # I like to use a frozen regexp for avoid reallocation, recompilation.
    #
    # But I like to use an instance method so we could swap out regexp depending
    # on parser context, when it's helpful.  Net::IMAP::ResponseParser does that.
    def lexer_regexp; LEXER_REGEXP end

    # integer    = nonzero digit* | "0"
    # float      = integer "." digit+
    # nonzero    = [1-9]
    # digit      = [0-9]
    #
    # Need to place T_FLOAT before T_INT, or else T_INT will match the partial
    # number before the decimal point.
    #
    # \G  => matches point where last match finished
    # \s* => at beginning and end to ignore whitespace
    LEXER_REGEXP = /\G\s*(?:\
(?# 1: T_FLOAT )((?:[1-9][0-9]*|0)\.[0-9]+)|\
(?# 2: T_INT   )([1-9][0-9]*|0)|\
(?# 3: T_LPAR  )(\()|\
(?# 4: T_RPAR  )(\))|\
(?# 5: T_PLUS  )(\+)|\
(?# 6: T_MINUS )(-)|\
(?# 7: T_TIMES )(\*)|\
(?# 8: T_DIV   )(\/)\
)\s*/.freeze

    # This needs to match up exactly with lexer_regexp captures.
    # Connescence of Position.
    def lexer_create_token(i, tval)
      case i
      when 1; Token.new(:T_FLOAT, Float(tval))
      when 2; Token.new(:T_INT,   Integer(tval))
      when 3; Token.new(:T_LPAR,  tval)
      when 4; Token.new(:T_RPAR,  tval)
      when 5; Token.new(:T_PLUS,  tval)
      when 6; Token.new(:T_MINUS, tval)
      when 7; Token.new(:T_TIMES, tval)
      when 8; Token.new(:T_DIV,   tval)
      else
        parse_error("Lexer bug: bad index")
      end
    end

    # The original definition is left recursive:
    #
    #   expression = term   | expression "+" term | expression "-" term
    #
    # This gives us left associativity:
    #   1 + 1 + 1 = (1 + 1) + 1
    # But it also means that it isn't an LL(k) grammar.
    # So we'll convert it to the following:
    #
    #   expression = term ("+" term | "-" term)*
    def expression
      lterm = term
      loop do
        if accept(:T_PLUS)
          lterm = Addition.new(lterm, term)
        elsif accept(:T_MINUS)
          lterm = Subtraction.new(lterm, term)
        else
          break
        end
      end
      lterm
    end

    # original definition:
    #    term = factor | term "*" factor | term "/" factor
    # rewritten to remove left-recursion:
    #    term = factor ("*" factor | "/" factor)*
    def term
      lfactor = factor
      loop do
        if accept(:T_TIMES)
          lfactor = Multiplication.new(lfactor, factor)
        elsif accept(:T_DIV)
          lfactor = Division.new(lfactor, factor)
        else
          break
        end
      end
      lfactor
    end

    # factor = number  | "(" expression ")"
    def factor
      if number?
        number
      else
        match(:T_LPAR)
        expr = expression
        match(:T_RPAR)
        expr
      end
    end

    # number = integer | float
    def number
      token = match(:T_INT, :T_FLOAT)
      Number.new(token.value)
    end

    # convenience acceptance method for lookahead
    def number?
      lookahead?([:T_INT, :T_FLOAT])
    end

  end

end
