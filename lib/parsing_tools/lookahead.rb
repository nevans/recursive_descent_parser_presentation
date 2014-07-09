module ParsingTools

  module Lookahead

    # Beware that any k > 1 consumes all tokens within the same @lex_state.
    # i.e. you cannot lookahead(2) unless it is okay for the next two tokens
    # to used the same @lex_state.
    def lookahead(k=1)
      @tokens ||= []
      while @tokens.size < k
        @tokens << next_token
      end
      (k == 1) ? @tokens[0] : @tokens[0,k]
    end

    def shift_token
      @tokens.any? ? @tokens.shift : next_token
    end

    def match(*args)
      token = lookahead
      unless token && args.include?(token.type)
        parse_error('unexpected token %s (expected %s)',
                    token.type.id2name,
                    args.collect {|i| i.id2name}.join(" or "))
      end
      shift_token
      return token
    end

    # like match, but does not raise error on failure.
    # returns and shifts token on success
    # returns nil and leaves @tokens on failure
    def accept(*args)
      token = lookahead
      return unless token
      if args.include?(token.type)
        shift_token
        token
      end
    end

    # convenience matcher
    # checks to see if the next several tokens match,
    # but does not consume them.
    def lookahead?(*args)
      tokens = [lookahead(args.length)].flatten
      args.zip(tokens).all? {|arg, token|
        possible_types = Array(arg)
        if token.nil?
          possible_types.empty? || possible_types.include?(nil)
        else
          possible_types.include?(token.type)
        end
      }
    end

  end

end
