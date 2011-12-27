class Expression < Numeric

  class Expr < Expression
    def self.new *args
      object = allocate
      object.send :initialize, *args
      object
    end
  end

  class UnOp < Expr

    attr_reader :val

    def initialize val
      @val = val
    end

    def == other
      case other
      when UnOp
        @val == other.val
      when Numeric
        @val == other
      else
        false
      end
    end

    def to_s
      @val.to_s
    end

    def inspect
      self.to_s
    end

    def debug
      "#{ self.class }( #{ @val } )"
    end

  end

  class BiOp < Expr

    attr_reader :l_oper, :r_oper

    def initialize l, r
      @l_oper = l
      @r_oper = r
    end

    def == other
      case other
      when BiOp
        @l_oper == other.l_oper && @r_oper == other.r_oper
      else
        false
      end
    end

    def sub hash

      @l_oper = @l_oper.sub hash
      @r_oper = @r_oper.sub hash

      self
    end

    def simplify
      @l_oper = @l_oper.simplify
      @r_oper = @r_oper.simplify

      self.apply
    end

    def inspect
      self.to_s
    end

    def debug
      "#{ self.class }( #{ @l_oper.debug }, #{ @r_oper.debug } )"
    end

  end

  class Const < UnOp

    def self.new(val, raw=false)
      if val < 0 && !raw
        return Neg.new( Const.new( -1*val ) )
      else
        object = allocate
        object.send :initialize, val
        return object
      end
    end

    def method_missing meth, *args, &block
      v = @val.send meth, *args, &block
      
      case v
      when @val.class
        @val = v
        return self
      when Expression
        return v
      when Numeric
        return Const.new( v )
      end
    end

  end

  class Mat < UnOp
    
    def initialize mat
      @val = mat.map do |elem|
        case elem
        when Expression
          elem
        when Numeric
          Const.new( elem )
        end
      end
    end

    def apply
      @val = @val.map &:apply
      self
    end

    def simplify
      @val = @val.map &:simplify
      self
    end

    def sub hash
      @val = @val.map do |elem|
        elem.sub hash
      end
      self
    end

    def map &block
      @val = @val.map &block
      self
    end
    
    def display
      @val.display
    end

  end

  class MatFun < UnOp

    def simplify
      @val = @val.simplify
      self.apply
    end

    def sub hash
      @val = @val.sub hash
      self
    end

    def debug
      "#{self.class}( #{ @val.debug } )"
    end

  end

  class Trn < MatFun

    def apply
      case @val
      when Mat
        return Mat.new( @val.val.trn ).simplify
      else
        self
      end
    end

    def to_s
      "trn(#{ @val })"
    end

  end

  class Cofactors < MatFun

    def apply
      case @val
      when Mat
        return Mat.new( @val.val.cofactors ).simplify
      else
        self
      end
    end

    def to_s
      "cofactors(#{ @val })"
    end

  end

  class Inverse < MatFun

    def apply
      case @val
      when Mat
        
        unless @val.det.simplify == 0
          return @val.val.inverse.simplify
        else
          raise SingularMatrixError.new(@val.val), "Attempted to invert a singular matrix"
        end
        
      else
        self
      end
    end

    def to_s
      "inverse(#{ @val })"
    end

  end

  class Det < MatFun

    def apply
      case @val
      when Mat
        d = @val.val.det
        case d
        when Expression
          return d.simplify
        when Numeric
          return Const.new( d )
        end
      else
        self
      end
    end

    def to_s
      "det(#{ @val })"
    end

  end

  class Var < UnOp

    def sub hash
      if hash.keys.include? @val
        case hash[@val]
        when Expression
          return hash[@val]
        when Numeric
          return Const.new(hash[@val])
        else
          self
        end
      end

      self
    end

  end

  class Neg < UnOp

    def sub hash
      @val = @val.sub hash
      self
    end

    def simplify

      @val = val.simplify

      case @val
      when Neg                   # Negation of a negation
        return @val.val.simplify # -(-a) = a
      when Mat
        return @val.map { |e| Neg.new( e ).simplify }
      end

      self.apply
    end

    def to_s
      "-#{@val}"
    end

    def debug
      "#{ self.class }( #{ @val.debug }  )"
    end

  end

  class Add < BiOp

    def == other
      case other
      when BiOp
        equals =   @l_oper == other.l_oper && @r_oper == other.r_oper
        equals ||= @l_oper == other.r_oper && @r_oper == other.l_oper
        equals
      else
        false
      end
    end

    def to_s
      paren_op_show @l_oper, "+", @r_oper
    end

    def apply
      # Addition of two constants
      if Const === @l_oper && Const === @r_oper
        return Const.new( @l_oper.val + @r_oper.val )
      end

      # Addition of two matrices
      if Mat === @l_oper && Mat === @r_oper
        return Mat.new( (@l_oper.val + @r_oper.val) ).simplify
      end

      # Addition with the addition unit
      if @l_oper == Const.new( 0 )
        return @r_oper
      elsif @r_oper == Const.new( 0 )
        return @l_oper
      end

      return self
    end

    def simplify
      
      @l_oper = @l_oper.simplify
      @r_oper = @r_oper.simplify

      # Addition with a negative number
      if Neg === @l_oper
        return Sub.new(@r_oper, @l_oper.val).simplify
      elsif Neg === @r_oper
        return Sub.new(@l_oper, @r_oper.val).simplify
      end

      self.apply
    end

  end

  class Sub < BiOp

    def to_s
      paren_op_show @l_oper, "-", @r_oper
    end

    def apply
      # Subtraction of one constant from another
      if Const === @l_oper && Const === @r_oper
        return Const.new( @l_oper.val - @r_oper.val )
      end

      # Subtraction of two matrices
      if Mat === @l_oper && Mat === @r_oper
        return Mat.new( @l_oper.val - @r_oper.val ).simplify
      end

      if @l_oper == Const.new( 0 )    # Subtraction from 0 (Negation)
        return Neg.new( @r_oper )     # 0-a = -a
      elsif @r_oper == Const.new( 0 ) # Subtraction of 0
        return @l_oper                # a-0 = a
      end

      self
    end

    def simplify

      @l_oper = @l_oper.simplify
      @r_oper = @r_oper.simplify

      if Neg === @r_oper              # Subtraction of a negative number.
        return Add.new( @l_oper, @r_oper.val ).simplify # a-(-b) = a+b
      elsif Neg === @l_oper
        return Neg.new(Add.new(@l_oper.val, @r_oper).simplify) # -a-b = -(a+b)
      end

      self.apply
    end

  end

  class Mult < BiOp

    def == other
      case other
      when BiOp
        equals = @l_oper == other.l_oper && @r_oper == other.r_oper
        equals ||= @l_oper == other.r_oper && @r_oper == other.l_oper
        equals
      else
        false
      end
    end

    def to_s
      if Var === @l_oper || Var === @r_oper
        implicit_op_show @l_oper, @r_oper
      else
        paren_op_show @l_oper, "*", @r_oper
      end
    end

    def apply
      # Mutliplication of two constants
      if Const === @l_oper && Const === @r_oper
        return Const.new( @l_oper.val * @r_oper.val )
      end

      # Multiplication involving matrices
      if Mat === @l_oper && Mat === @r_oper
        return Mat.new( @l_oper.val * @r_oper.val ).simplify
      elsif Mat === @l_oper
        return Mat.new( @l_oper.val.map { |e| e * @r_oper } ).simplify
      elsif Mat === @r_oper
        return Mat.new( @r_oper.val.map { |e| @l_oper * e } ).simplify
      end

      # Multiplication with 0
      if @l_oper == Const.new( 0 ) || @r_oper == Const.new( 0 )
        return Const.new( 0 )   # 0*a = 0
      end

      # Multiplication with the identity
      if @l_oper == Const.new( 1 )
        return @r_oper          # 1*a = a
      elsif @r_oper == Const.new( 1 )
        return @l_oper          # a*1 = a
      end

      self
    end

    def simplify
      @l_oper = @l_oper.simplify
      @r_oper = @r_oper.simplify

      # Multiplication involving negatives
      if Neg === @l_oper && Neg === @r_oper # (-a)*(-a) = a*a
        return Mult.new( @l_oper.val, @r_oper.val ).simplify
      elsif Neg === @l_oper && !(Mat === @r_oper) # (-a)*a = -(a*a)
        return Neg.new( Mult.new( @l_oper.val, @r_oper).simplify )
      elsif Neg === @r_oper && !(Mat === @l_oper) # a*(-a) = -(a*a)
        return Neg.new( Mult.new( @l_oper, @r_oper.val).simplify )
      end

      self.apply
    end

  end

  class Div < BiOp

    def to_s
      paren_op_show @l_oper, "/", @r_oper
    end

    def apply
      
      if @l_oper == Const.new( 0 )    # Division of 0
        return Const.new( 0 )         # 0/a = 0
      elsif @r_oper == Const.new( 0 ) # Division by 0 (MATHEMATICALLY UNDEFINED)
        raise ZeroDivisionError, "Cannot divide #{ @l_oper } by 0"
      end
      
      # Divison of two constants
      if Const === @l_oper && Const === @r_oper
        return Const.new( @l_oper.val.to_f / @r_oper.val )
      end

      if Mat === @l_oper
        return Mat.new( @l_oper.val * (1.0/@r_oper) ).simplify
      end

      if @r_oper == Const.new( 1 ) # Division by 1
        return @l_oper             # a/1 = a
      end

      self
    end

    def simplify
      @l_oper = @l_oper.simplify
      @r_oper = @r_oper.simplify

      # Division involving negative values
      if Neg === @l_oper && Neg === @r_oper
        return Div.new( @l_oper.val, @r_oper.val ).simplify    # (-a)/(-a) = a/a
      elsif Neg === @l_oper
        return Neg.new(Div.new(@l_oper.val, @r_oper).simplify) # (-a)/a= -(a/a)
      elsif Neg === @r_oper
        return Neg.new(Div.new(@l_oper, @r_oper.val).simplify) # a/(-a)= -(a/a)
      end

      self.apply
    end

  end

  class Pow < BiOp

    def to_s

      _l = @l_oper.to_s
      _r = @r_oper.to_s

      l = /^\(.+\)$/ =~ _l || !(Mult === @l_oper) ? _l : "(#{ _l })"
      r = /^\(.+\)$/ =~ _r || !(Mult === @r_oper) ? _r : "(#{ _r })"

      paren_op_show l, "^", r
    end

    def apply
      # Indices with constant values
      if Const === @l_oper && Const === @r_oper
        return Const.new( @l_oper.val ** @r_oper.val )
      end

      # Indices where either operand is 0
      if @r_oper == Const.new( 0 )
        return Const.new( 1 )   # a^0 = 1
      elsif @l_oper == Const.new( 0 )
        return Const.new( 0 )   # 0^a = 0
      end

      # Indices where either operand is 1
      if @r_oper == Const.new( 1 )
        return @l_oper          # a^1 = a
      elsif @l_oper == Const.new( 1 )
        return Const.new( 1 )   # 1^a = 1
      end

      self
    end

    def simplify
      @l_oper = @l_oper.simplify
      @r_oper = @r_oper.simplify

      # Negative indices
      if Neg === @r_oper        # a^(-b) = 1/(a^b)
        return Div.new(Const.new(1),Pow.new(@l_oper,@r_oper.val)).simplify
      end

      self.apply
    end

  end

  def coerce other
    case other
    when Matrix
      return Mat.new( other ), self
    when Numeric
      return Const.new( other ), self
    else
      raise TypeError, "Cannot coerce #{ other.class } to Expression"
    end
  end

  def self.new val
    case val
    when String
      Var.new( val.to_sym )
    when Symbol
      Var.new( val )
    when Matrix
      Mat.new( val )
    when Numeric
      Const.new( val )
    else
      raise TypeError, "Cannot create Expression from #{ val.class }"
    end
  end

  def + other
    case other
    when Expression
      Add.new( self, other )
    when Matrix
      Add.new( self, Mat.new( other ) )
    when Numeric
      Add.new( self, Const.new(other) )
    else
      x, y = other.coerce self
      x + y
    end
  end

  def - other
    case other
    when Expression
      Sub.new( self, other )
    when Matrix
      Sub.new( self, Mat.new( other ) )
    when Numeric
      Sub.new( self, Const.new(other) )
    else
      x, y = other.coerce self
      x - y
    end
  end

  def * other
    case other
    when Expression
      Mult.new( self, other )
    when Matrix
      Mult.new( self, Mat.new( other ) )
    when Numeric
      Mult.new( self, Const.new(other) )
    else
      x, y = other.coerce self
      x * y
    end
  end

  def / other
    case other
    when Expression
      Div.new( self, other )
    when Matrix
      Div.new( self, Mat.new( other ) )
    when Numeric
      Div.new( self, Const.new(other) )
    else
      x, y = other.coerce self
      x / y
    end
  end

  def ** other
    case other
    when Expression
      Pow.new( self, other )
    when Numeric
      Pow.new( self, Const.new(other) )
    else
      x, y = other.coerce self
      x ** y
    end
  end

  def -@
    Neg.new( self )
  end

  def trn
    return Trn.new( self )
  end

  def cofactors
    return Cofactors.new( self )
  end

  def inverse
    return Inverse.new( self )
  end

  def det
    return Det.new( self )
  end

  def < other
    false if other == 0
  end

  def sub hash
    self
  end

  def apply
    self
  end

  def simplify
    self
  end

  def display
    to_s
  end

  def paren_op_show l, op, r
    "(#{l}#{op}#{r})"
  end

  def implicit_op_show l, r
    "#{l}#{r}"
  end

  def debug
    "#{ self.class }"
  end

end
