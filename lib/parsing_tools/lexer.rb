module ParsingTools
  module Lexer

    def parsing(str)
      @str    = str
      @pos    = 0
      @tokens = []
    end

    # Requires three helper methods:
    #   * lexer_regexp
    #   * lexer_create_token(i, tval)
    #   * parse_error(fmt, *args)
    def next_token
      return nil unless @str
      return nil if @pos >= @str.length
      if match = lexer_regexp.match(@str, @pos)
        @pos = match.end(0)
        i = 0
        tval = match.captures.find {|c| i += 1; c }
        if tval
          lexer_create_token(i, tval)
        else
          parse_error("Lexer bug: missing tval")
        end
      else
        @str.index(lexer_error_tokenizer, @pos)
        parse_error("unknown token - %s", $&.dump)
      end
    end

    # can be overridden, but by default finds the next word.
    def lexer_error_tokenizer
      /\s*\S*/n
    end

  end
end
