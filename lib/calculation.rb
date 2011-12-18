# require "./Expression.rb"
# require "./Matrix.rb"

class Calculation
  attr_reader :calc, :vars, :mats, :ans

  def initialize

    @calc = Expression.new( 0 ) # Variable to store current calculation

    @vars = {}                  # Hash (Dictionary) of symbols to values.
    @mats = {}                  # Hash of symbols to matrices.
    @exps = {}                  # Hash of allowed symbols
    @ans  = 0                   # Result from last calculation.

    ('a'..'z').each do |c|      # For each letter in the alphabet

      @vars[c.to_sym]        = nil # Set variable of that letter to nil.
      @mats[c.upcase.to_sym] = nil # Set matrix for uppercase of letter to nil.

    end

  end

  ('a'..'z').each do |char|
    define_method(char.to_sym) { Expression.new( char ) }
    self.const_set(char.upcase.to_sym, Expression.new( char.upcase ))
  end

  self.const_set(:Ans, Expression.new( '&' ))

  def trn oper
    oper.trn
  end

  def cofactors oper
    oper.cofactors
  end

  def inverse oper
    oper.inverse
  end

  def det oper
    oper.det
  end

  def parse str

    _str = str
    str.gsub! /(\[\[[^\[\]]+\](?:,\[[^\[\]]+\])\])/, "Matrix\\1" # Implicit Matrices

    begin
      result = eval(str)        # Evaluate the substituted string.

      case result               # Check the evaluation.
      when Expression           # If it is an expression:
        @calc = result          # Set it as the current calculation.
      when Numeric, Matrix      # If it is a numeric (or a matrix):
        @calc = Expression.new( result ) # Set it as the current calculation.
      end

      return true               # Succesful Parse
    rescue => $error
      $strs = [_str, str]
      return false              # Failed Parse
    end

  end

  def calculate

    vars_com = @vars.select { |k,v| !v.nil? } # Remove nil subs in variables.

    mats_sub = @mats.merge(@mats) do |key, value|
      if !value.nil?
        val_copy = Marshal.load(Marshal.dump(value))
        val_copy.sub vars_com             # Perform substitutions on matrices.
      else
        nil
      end
    end

    mats_sub.select! { |k,v| !v.nil? } # Remove nil valued matric substitutions.

    puts @calc

    calc_sub = @calc.sub(:"&" => @ans ) # Substitute answer variable.
    calc_sub = calc_sub.sub( mats_sub ) # Substitute matrices.
    calc_sub = calc_sub.sub( vars_com ) # Substitute variables.

    @ans = calc_sub.simplify    # Simplify calculation, and set as answer.

    @ans                        # Return answer.
  end

  def save_state
    str = ""                    # Initialise string.

    @vars.each { |k,var| str << var.to_s << "\n" } # Add variables to string.
    @mats.each { |k,mat| str << mat.to_s << "\n" } # Add matrices to string.

    str                         # Return string.
  end

  def load_state str
    i = 0                       # Initialise counter variable.

    str.each_line do |l|        # Iterate through every line in the file:
      if i < 26                 # Record numbers fewer than 26 are for vars.

        if l.chomp != ""        # Check that the line is not empty:

          num = l.to_f          # Let ruby parse it as a float.
          num = num.to_i if l.to_f == l.to_i # Simplify to an int if possible.

        else                    # If the line is empty:

          num = nil             # Set the number to empty.

        end

        # Calculate char's ASCII code.
        # Convert to a character, and then a symbol.
        # Set the value for the symbol in the variables list as num.
        @vars[(97+i).chr.to_sym] = num

      else                      # Record numbers greater than 26 are for mats:

        _i = i-26               # Calculate index in @mats from record number.

        # Check line not empty & fits matrix pattern (enclosed in [ ]):
        if l != "" && /^\[(.+)\]$/ =~ l

          rows = []             # Initialise rows for matrix.
          capture = $1          # Store the contents within the [ ].

          # Check for further square brackets within the contents.
          # For each square bracket, add the string of the contents to rows.
          capture.gsub(/\[([^\[\]]+)\]/) { |m| rows << $1 }

          # Split each row in strings across the commas.
          # This creates the string representations of the elements.
          rows.map! { |r| r.split ", " }
          mat_str = Matrix[ *rows ] # Initialise a matrix with these elements.

          mat = mat_str.map do |elem| # Iterate through each of these elements.

            case elem           # Check the element:
            when /^[a-z]$/      # If it is a single character.
              Expression.new( elem ) # Create an expression from it (a var).
            when /^\d+$/        # If it is a arbitrary length string of numbers.
              Expression.new( elem.to_i ) # Create an expression (an int const).
            when /^\d+\.\d+$/   # If it also has a single . in it.
              Expression.new( elem.to_f ) # Create expression (a float const).
            end

          end

        else                    # If line was empty or did not match pattern:
          mat = nil             # Set matrix to empty.
        end

        # Calculate char's ASCII code using _i (not i).
        # Convert to a character, and then a symbol.
        # Set the value for the symbol in the matrices list as mat.
        @mats[(65+_i).chr.to_sym] = mat
      end

      i += 1                    # Increment counter.
    end

  end

  def add_var id, val

    # Check valid range
    raise ArgumentError, "No such ID" if !('a'..'z').include?(id)

    case val                    # Check variable:
    when Expression             # Expressions
      @vars[id.to_sym] = val.simplify # must be simplified.
    when Numeric                # Numbers
      @vars[id.to_sym] = val    # can simply be assigned.
    end

  end

  def clear_var id
    # Check valid range
    raise ArgumentError, "No such ID" if !('a'..'z').include?(id)

    @vars[id.to_sym] = nil      # Set variable to empty.
  end

  def add_matrix id, *rows

    # Check valid range
    raise ArgumentError, "No such ID" if !('A'..'Z').include?(id)

    m = Matrix[ *rows ]         # Create unchecked matrix

    mat = m.map do |elem|       # Check each value in unchecked matrix

      case elem
      when Expression           # Expressions
        elem.simplify           # Are simplified and then returned.
      when String, Symbol, Numeric # Strings, Symbols and Numbers
        Expression.new( elem )     # are converted in to Expressions.
      else
        Expression.new( 0 )     # Everything else is set to 0.
      end

    end

    # Set the appropriate symbol to a Matric Expression.
    @mats[id.to_sym] = Expression.new( mat )

  end

  def clear_matrix id
    # Check valid range
    raise ArgumentError, "No such ID" if !('A'..'Z').include?(id)

    @mats[id.to_sym] = nil      # Set matrix to empty.
  end

end
