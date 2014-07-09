module ParsingTools

  class ParseError < StandardError
  end

  module ErrorHandling

    def debug!(puts_caller: true)
      caller[0,10].each.with_index do |c,i|
        $stderr.printf("caller[%d]: %s\n", i, c)
      end if puts_caller
      $stderr.printf("@str: %p\n", @str)
      $stderr.printf("@pos: %d\n", @pos)
      $stderr.printf("@str until @pos: %p\n", @str[0,@pos])
      @tokens.each.with_index do |t,i|
        $stderr.printf("@tokens[%d]: %s %p\n", i, t.type, t.value)
      end
    end

    def parse_error(fmt, *args)
      debug!  if @debug
      raise ParseError, fmt % args
    end

  end

end
