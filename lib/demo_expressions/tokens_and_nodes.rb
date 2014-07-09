module DemoExpressions

  # minimal Token implementation
  class Token < Struct.new(:type, :value)
  end

  class Number < Struct.new(:value)
    def number?;    true  end
    def operation?; false end
    def evaluate;   value end
  end

  class Operation < Struct.new(:lval, :rval)
    def number?;    false end
    def operation?; true  end
  end

  class Addition < Operation
    def value; "(%s + %s)" % [lval.value, rval.value] end
    def evaluate; lval.evaluate + rval.evaluate end
  end

  class Subtraction < Operation
    def value; "(%s - %s)" % [lval.value, rval.value] end
    def evaluate; lval.evaluate - rval.evaluate end
  end

  class Multiplication < Operation
    def value; "(%s * %s)" % [lval.value, rval.value] end
    def evaluate; lval.evaluate * rval.evaluate end
  end

  class Division < Operation
    def value; "(%s / %s)" % [lval.value, rval.value] end
    def evaluate; lval.evaluate / rval.evaluate end
  end

end
