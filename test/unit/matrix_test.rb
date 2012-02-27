require "./Matrix.rb"           # Include classes to be tested
require "test/unit"             # Include Unit Testing framework

class MatrixTest < Test::Unit::TestCase

  def test_addition_valid
    mX = Matrix[ [1,2],[3,4] ]
    mY = Matrix[ [5,6],[7,8] ]

    assert_equal( mX + mY, Matrix[ [6,8],[10,12] ] )
  end

  def test_addition_invalid
    mX = Matrix[ [1,2],[3,4] ]
    mY = Matrix[ [3] ]

    assert_raise( ArgumentError ) { mX + mY }
  end

  def test_transposition_valid_2x2
    mX = Matrix[ [1,2],[3,4] ]
    
    assert_equal( mX.trn, Matrix[ [1,3],[2,4] ] )
  end

  def test_transposition_valid_3x3
    mX = Matrix[ [1,2,3],[4,5,6],[7,8,9] ]

    assert_equal( mX.trn, Matrix[ [1,4,7],[2,5,8],[3,6,9] ] )
  end

  def test_transposition_valid_non_square
    mX = Matrix[ [1,2,3],[4,5,6] ]

    assert_equal( mX.trn, Matrix[ [1,4],[2,5],[3,6] ] )
  end

  def test_transposition_fringe_empty
    mX = Matrix[ ]
    
    assert_equal( mX.trn, Matrix[ ] )
  end

  def test_multiplication_valid_2x2
    mX = Matrix[ [1,2],[3,4] ]
    mY = Matrix[ [5,6],[7,8] ]

    assert_equal( mX*mY, Matrix[ [19,22],[43,50] ] )
  end

  def test_multiplication_valid_3x3
    mX = Matrix[ [1,2,0],[3,2,1],[3,4,4] ]
    mY = Matrix[ [1,1,3],[2,1,0],[3,0,1] ]

    assert_equal( mX*mY, Matrix[ [5,3,3],[10,5,10],[23,7,13] ] )
  end

  def test_multiplication_invalid_dimensions
    mX = Matrix[ [1,2],[3,4] ]
    mY = Matrix[ [5,6],[7,8],[9,10] ]

    assert_raise( ArgumentError ) { mX * mY }
  end

  def test_multiplication_fringe_scalar_second
    mX = 2
    mY = Matrix[ [1,2],[3,4] ]

    assert_equal( mX*mY, Matrix[ [2,4],[6,8] ] )
  end

  def test_multiplication_fringe_scalar_first
    mX = Matrix[ [1,2],[3,4] ]
    mY = 2

    assert_equal( mX*mY, Matrix[ [2,4],[6,8] ] )
  end

  def test_cofactor_valid_2x2_1
    x, y = [1,1]
    mX   = Matrix[ [1,2],[3,4] ]

    assert_equal( mX.cofactor(x, y), 4 )
  end

  def test_cofactor_valid_2x2_2
    x, y = [2,1]
    mX   = Matrix[ [1,2],[3,4] ]

    assert_equal( mX.cofactor(x, y), -3 )
  end

  def test_cofactor_valid_3x3_1
    x, y = [1,1]
    mX   = Matrix[ [1,2,3],[4,5,6],[7,8,9] ]

    assert_equal( mX.cofactor(x,y), -3 )
  end

  def test_cofactor_valid_3x3_2
    x, y = [1,2]
    mX   = Matrix[ [1,2,3],[4,5,6],[7,8,9] ]

    assert_equal( mX.cofactor(x,y), 6 )
  end

  def test_cofactor_invalid_non_square
    x, y = [1,1]
    mX = Matrix[ [1,2,3],[4,5,6] ]

    assert_raise( ArgumentError ) { mX.cofactor(x, y) }
  end

  def test_cofactor_invalid_col_out_of_range
    x, y = [3,1]
    mX   = Matrix[ [1,2],[3,4] ]

    assert_raise( ArgumentError ) { mX.cofactor(x, y) }
  end

  def test_cofactor_invalid_row_out_of_range
    x, y = [1,3]
    mX   = Matrix[ [1,2],[3,4] ]

    assert_raise( ArgumentError ) { mX.cofactor(x, y) }
  end

  def test_cofactors_valid_2x2
    mX = Matrix[ [1,2],[3,4] ]

    assert_equal( mX.cofactors, Matrix[ [4,-3],[-2,1] ] )
  end

  def test_cofactors_valid_3x3
    mX = Matrix[ [1,2,3],[4,5,6],[7,8,9] ]

    assert_equal( mX.cofactors, Matrix[ [-3,6,-3],[6,-12,6],[-3,6,-3] ] )
  end

  def test_cofactors_invalid_non_square
    mX = Matrix[ [1,2,3],[4,5,6] ]

    assert_raise( ArgumentError ) { mX.cofactors }
  end

  def test_determinant_valid_2x2
    mX = Matrix[ [1,2],[3,4] ]
    
    assert_equal(mX.det, -2)
  end

  def test_determinant_valid_3x3
    mX = Matrix[ [1,2,3],[4,5,6],[7,8,9] ]

    assert_equal( mX.det, 0 )
  end

  def test_determinant_invalid_non_square
    mX = Matrix[ [1,2,3],[4,5,6] ]

    assert_raise( ArgumentError ) { mX.det }
  end

  def test_determinant_fringe_empty
    mX = Matrix[ ]

    assert_equal( mX.det, 1 )
  end

  def test_determinant_fringe_1x1
    mX = Matrix[ [2] ]

    assert_equal( mX.det, 2 )
  end

  def test_inverse_valid_2x2
    mX = Matrix[ [1,2],[3,4] ]
    
    assert_equal( mX.inverse, Matrix[ [-2,1],[1.5,-0.5] ] )
  end

  def test_inverse_valid_3x3
    mX = Matrix[ [1,0,1],[2,1,3],[1,3,5] ]
    
    assert_equal( mX.inverse, Matrix[ [-4,3,-1],[-7,4,-1],[5,-3,1] ] )
  end

  def test_inverse_invalid_non_square
    mX = Matrix[ [1,2,3],[4,5,6] ]
    
    assert_raise( ArgumentError ) { mX.inverse }
  end

  def test_inverse_fringe_singular
    mX = Matrix[ [1,2,3],[4,5,6],[7,8,9] ]
    
    assert_raise( ZeroDivisionError ) { mX.inverse }
  end

  def test_inverse_fringe_empty
    mX = Matrix[ ]

    assert_equal( mX.inverse, Matrix[ ] )
  end

  def test_random_valid_2x2
    size  = 2
    limit = 5
    rX    = Matrix.random(size, limit)

    assert_equal( rX.dim, Dimension.new( size, size ) )

    rX.map do |elem|
      assert_equal( elem.floor, elem )
      assert_in_delta(0, elem, limit)
    end
  end

  def test_random_nice_valid_2x2
    size  = 2
    limit = 2
    nX    = Matrix.nice( size, limit )
    nX_I  = nX.inverse

    assert_equal( nX.dim, Dimension.new( size, size ) )

    nX.map do |elem|
      assert_equal( elem.floor, elem )
      assert_in_delta( 0, elem, size*(limit**2) )
    end

    nX_I.map { |elem| assert_equal( elem.floor, elem ) }

  end

end
