module ParsingTools

  module Backtracking

    def save_parser_state
      {
        pos:       @pos,
        tokens:    @tokens.dup,
        debug:     @debug,
      }
    end

    def restore_parser_state(pos:       nil,
                             tokens:    nil,
                             debug:   false)
      @pos       = pos
      @tokens    = tokens
      @debug     = debug
    end

    # Given an array of methods, will try each method in turn.
    # Catches exceptions from failed attempts.
    # Will only raise exception from last attempt.
    #
    # call like so:
    #     backtrack(method(:foo), method(:bar), method(:baz))
    #
    def backtrack(first_method, *rest_methods, debug: false)
      state = save_parser_state
      @debug = debug if rest_methods.any?
      method(first_method).call
    rescue ParseError
      raise if rest_methods.empty?
      restore_parser_state(state)
      backtrack(*rest_methods)
    end

  end

end
