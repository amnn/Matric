Dimension = Struct.new(:x, :y)

class Matrix

  class ScalarMultiple < Numeric
    def initialize val
      @val = val
    end

    def + other
      case other
      when Numeric
        ScalarMultiple.new( @val + other )
      when Matrix
        raise TypeError, "Cannot add Matrix and Scalar"
      else
        x, y = other.coerce self
        x + y
      end
    end

    def - other
      case other
      when Numeric
        ScalarMultiple.new( @val - other )
      when Matrix
        raise TypeError, "Cannot subtract Matrix from Scalar"
      else
        x, y = other.coerce self
        x - y
      end
    end

    def * mat_y
      case mat_y
      when Numeric
        ScalarMultiple.new( @val * mat_y )
      when Matrix
        mat_y.map { |e| e*@val }
      else
        x, y = mat_y.coerce self
        x * y
      end
    end

    def / other
      case other
      when Numeric
        ScalarMultiple.new( @val / other )
      when Matrix
        raise TypeError, "Cannot divide Scalar by Matrix"
      else
        x, y = other.coerce self
        x / y
      end
    end

    def ** other
      case other
      when Numeric
        ScalarMultiple.new( @val ** other )
      when Matrix
        raise TypeError, "Cannot take Scalar to a Vector power"
      else
        x, y = other.coerce self
        x ** y
      end
    end
  end

  def coerce other

    case other
    when Numeric
      return ScalarMultiple.new( other ), self
    else
      raise TypeError, "Cannot Coerce #{ other.class } to work with Matrix"
    end

  end

  attr_accessor :rows

  class << self
    def [] *rows
      self.new *rows
    end

    # Matrix Generation Functions

    # Zero Matrix

    def zero n
      rows_x = []
      n.times { rows_x << [0]*n }
      Matrix[ *rows_x ]
    end

    # Identity Matrix

    def identity n
      rzero_n = zero(n).rows
      n.times { |i| rzero_n[i][i] = 1 }
      Matrix[ *rzero_n ]
    end

    # Random Integer Matrix

    def random size, limit
      row_x = []                # Define element array.

      size.times { row_x << [] } # Initialise element array.

      size.times do |j|         # For each row:
      size.times do |i|         # Set each element

        # To a random value, between -limit and +limit
        row_x[j][i] = ( rand(2) == 0 ? 1 : -1 ) * rand(limit)

      end
      end

      # Return a Matrix instance with the elements in the array.
      Matrix[ *row_x ]
    end

    # Random Integer Nice Invertible Matrix

    def nice size, limit

      row_l = []                # Define constituent element arrays.
      row_u = []

      # Initialise element arrays
      size.times { row_l << []; row_u << [] }

      size.times do |j|         # For each row:
      size.times do |i|         # Iterate through every element

          if i < j              # Left of principal diagonal:

            row_l[j][i] = rand(limit) # L has a random value
            row_u[j][i] = 0           # U has 0

          elsif i == j          # On the principal diagonal:

            row_l[j][i] = 1           # L is 1
            row_u[j][i] = 1           # U is 1

          elsif i > j           # Right of principal diagonal:

            row_l[j][i] = 0           # L is 0
            row_u[j][i] = rand(limit) # U is random value

          end

      end
      end

      # Return a matrix
      Matrix[ *row_l ] * Matrix[ *row_u ]
    end

  end

  def initialize *rows
    @rows = rows
  end

  def to_s
    @rows.to_s
  end

  def inspect
    to_s
  end

  def display
    mat_str = self.map { |e| e.to_s }
    mat_len = mat_str.map { |e| e.length }

    col_widths = mat_len.trn.rows.map { |row| row.max }

    s_mat_x = "+"

    col_widths.each { |width| s_mat_x << "-"*(width+2) << "+" }

    mat_str.rows.each do |row|
      s_mat_x << "\n|"

      row.each_with_index do |elem, i|
        s_mat_x << " " <<  elem.rjust(col_widths[i],' ') << " |"
      end
    end

    s_mat_x += "\n+"
    
    col_widths.each { |width| s_mat_x << "-"*(width+2) << "+" }

    s_mat_x
  end

  # Convenience functions, Abstractions and Common Constructs

  def [] x, y
    @rows[y][x]
  end

  def dim
    d = Dimension.new

    if self.is_empty?
      d.x = 0; d.y = 0
    else
      d.x = @rows[0].size
      d.y = @rows.size
    end

    return d
  end

  def is_empty?
    @rows.size == 0
  end

  def is_square?
    d = dim()

    return true if d.x == d.y
    return false
  end

  # Map / Collect

  def map #yield#
    d      = dim()              # Store dimension of original matrix.
    rows_y = []                 # Define element array.

    # Add correct no. of (empty) rows to element array.
    d.y.times { rows_y << [] }

    d.y.times do |j|            # For each row in self:
    d.x.times do |i|            # Iterate throuch each element

      # Send each element to the block attacked to map,
      # collecting the results in the element array.
      rows_y[j][i] = yield @rows[j][i]

    end
    end

    Matrix[ *rows_y ]           # Return a matrix with those elements.
  end

  # Without Row

  def without_row r
    raise ArgumentError, "Row #{r} is out of range" if r > dim().y

    # Take all the rows before r and all the rows after r
    rows_y = @rows.take(r-1) + @rows.drop(r)

    # Create a matrix with the new rows
    Matrix[ *rows_y ]
  end

  # Without Col

  def without_col c
    raise ArgumentError, "Column #{c} is out of range" if c > dim().x

    # Recycle the without_row implementation
    trn.without_row(c).trn
  end

  # Matrix Operations

  # Transposition
  def trn
    if self.is_empty?           # Return self, if self is an empty matrix.
      return self
    end

    rows_y = []                 # Initialise resultant/answer matrix.
    dim_x  = dim()              # Store dimensions of self.

    dim_x.x.times { rows_y << [] } # Fill answer matrix with correct number
                                   # of (empty) rows.
    dim_x.y.times do |j|
    dim_x.x.times do |i|        # Iterate through each element in the matrix.
      rows_y[i][j] = self[i,j]  # Set ans[i,j] to self[j,i] (reflect values
    end                         # about top-left to bottom-right diagonal).
    end

    return (Matrix[ *rows_y ])  # Return matrix with transposed elements.
  end

  # Cofactor

  def cofactor x, y

    # If the remainder of the coordinate sum divided by two is 0, then do not
    # change the sign of the cofactor, otherwise, negate it. (Ternary operator)
    sign  = (x+y)%2 == 0 ? 1 : -1

    # Find the Minor matrix for the cofactor (The matrix left when the yth row
    # xth column have been removed from the original matrix).
    minor = self.without_row(y).without_col(x)

    # The cofactor is the determinant of this minor matrix, multiplying with
    # sign simply corrects its sign.
    sign * minor.det
  end

  # Cofactors

  def cofactors
    d      = dim()              # Store dimensions for later use.
    rows_y = []                 # Define resultant element array.

    # Initialise element array with correct no. of (empty) rows.
    d.y.times { rows_y << [] }

    d.y.times do |j|            # For each row in self:
    d.x.times do |i|            # Iterate through each element:

      # Collect the cofactor for self[i, j] in ans[i, j].
      rows_y[j][i] = self.cofactor(i+1, j+1)

    end
    end

    # Return a matrix with elements from the resultant array.
    Matrix[ *rows_y ]
  end

  # Determinant

  def det
    d = dim()                   # Store dimensions for later use.

    if self.is_empty?           # If matrix is empty:

      return 1                  # Determinant is 1.

    elsif d.x == 1 && d.y == 1  # If matrix is 1x1:

      return self[0,0]          # Determinant is the only value in the matrix.

    elsif self.is_square?       # If matrix is any other square matrix:

      determinant = 0           # Initialise determinant variable.

      d.x.times do |i|          # Iterate through every element in the 1st row.

        # Add to the determinant the product of the element with its cofactor.
        determinant += self[i,0] * self.cofactor(i+1,1)

      end

      return determinant        # Return determinant
    else                        # If matrix is not square:

      # Raise an ArgumentError
      raise ArgumentError, "Matrix must be square for this calculation"

    end

  end

  # Inverse

  def inverse
    det_x = self.det            # Calculate the determinant.
    d     = dim()               # Store the dimension for later use.

    if det_x == 0               # If the determinant is 0:

      raise ZeroDivisionError, "Matrix is Singular" # Cannot invert the matrix.

    elsif self.is_empty?        # If the matrix is empty:

      return self               # Return an empty matrix.

    elsif d.x == 1 && d.y == 1  # For a 1x1 matrix:

      return Matrix[ [1.0/det_x] ] # Return 1/det in a 1x1 matrix.

    else

      # Calculate the transposition of the cofactors matrix.
      tmat_c = self.cofactors.trn

      # Multiply with the reciprocal of the determinant to get the inverse.
      mat_i  = (1.0/det_x) * tmat_c

      return mat_i              # Return the inverse.
    end
  end

  # Mathematical Operators

  # Addition
  def + mat_y

    # Check to ensure that the parameter passed in is also a matrix.
    # If not, raise TypeError, as only matrices can be added to other matrices.
    if !(mat_y.kind_of? Matrix)
      x, y = mat_y.coerce self
      return x + y
    end

    # Store the dimensions of both matrices
    dim_x = dim()
    dim_y = mat_y.dim

    # Matrices must have exactly the same dimensions to be added together.
    if dim_x == dim_y
      rows_z = [] # Define the content of the resultant matrix as an empty list.

      # Fill the resultant matrix  with empty rows, to populate with values.
      dim_x.y.times { rows_z << [] }

      dim_x.y.times do |j|
      dim_x.x.times do |i|
        # Iterate through each coordinate in the matrices.
        # Set the value of the coord in the resultant as the sum of the value in
        # this matrix and the value in the matrix being added to it for the
        # given coordinates.
        rows_z[j][i] = self[i,j] + mat_y[i,j]
      end
      end

      # Return the resultant values, in a matrix.
      return (Matrix[ *rows_z ])
    else
      # If the dimensions do not match, raise an ArgumentError
      raise ArgumentError, "Cannot add Matrices of differing dimensions"
    end
  end

  # Subtraction

  def - mat_y
    self + mat_y*(-1)           # Addition with the negative scalar multiple.
  end

  # Multiplication

  def * mat_y
    case mat_y
    when Numeric                # If mat_y is a numeric value (A scalar):

      # Multiply every element in self by it and return the resultant matrix.
      self.map { |e| e * mat_y }

    when Matrix                 # If however, mat_y is a matrix:

      dim_x  = dim()            # Store the dimensions of self and mat_y
      dim_y  = mat_y.dim        # in dim_x and dim_y respectively.

      if dim_x.x != dim_y.y     # Check that the 1st width and 2nd height match.
        # If they do not, raise an ArgumentError
        raise ArgumentError, "1st width and 2nd height must match"
      end

      rows_z = []               # Define the resultant matrix's element array.
      elem   = 0                # Define and initialise accumulator variable.

      # Initialise element array with correct number of (empty) rows.
      dim_x.x.times { rows_z << [] }

      dim_x.y.times do |r|      # For each row in self:
      dim_y.x.times do |c|      # Iterate through every column in mat_y:
        elem = 0                # Reset accumulator variable

        dim_x.x.times do |i|    # Iterate through each element in row/column.

          # Add to the accumulator the product of the ith element of the row
          # vector self_r with the ith element of the column vector mat_y_c.
          elem += self[i, r] * mat_y[c, i]

        end

        # Put elem in the element array where row r and column c intersect
        # I.e. at the coordinate (c, r).
        rows_z[r][c] = elem
      end
      end

      # Return the matrix composed of the elements in the element array.
      Matrix[ *rows_z ]

    else                        # If Matrix does not know about mat_y's type:

      x, y = mat_y.coerce self  # Attempt to make mat_y change self in such a
      x * y                     # way that self knows how to * mat_y.

    end
  end

  def == other
    case other
    when Matrix
      @rows == other.rows
    else
      false
    end
  end

  def < other
    false if other == 0
  end

end
