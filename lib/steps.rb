Steps = Struct.new(:instructions, :result, :further_steps)

class Expression::UnOp
  
  def steps
    return @val.respond_to?(:steps) ? @val.steps : []
  end
  
end

class Expression::BiOp
  
  def steps
    return @l_oper.steps + @r_oper.steps
  end
  
end

class Expression::Inverse
  
  def steps
    
    the_steps   = []
    value       = @val.simplify
    dim         = value.val.dim
    determinant = value.det.simplify
    
    the_steps << Steps["Invert matrix.", value.display, nil]
    
    the_steps << Steps["Calculate the determinant.", determinant.display, value.det.steps]
    
    the_steps << Steps["(If the determinant is 0, The matrix cannot be inverted.)", nil]
    
    unless determinant == 0
      if dim.x > 1 && dim.y > 1
        cofactors = value.cofactors.simplify
        inverted  = ((1.0/determinant)*cofactors.trn).simplify
      
        the_steps << Steps["Calculate the cofactors matrix.", cofactors.display, value.cofactors.steps]
        the_steps << Steps["Transpose the coractors matrix.", cofactors.trn.simplify.display]
        the_steps << Steps["Multiply the reciprocal of the determinant with the transpose of the cofactors matrix.", inverted.display, nil]
      else
        case dim
        when Dimension[0,0]
          the_steps << Steps["The inverse of an empty matrix is another empty matrix", value.display ]
        when Dimension[1,1]
          the_steps << Steps["The inverse of a 1x1 matrix is the reciprocal of its determinant", value.inverse.display ]
        end
      end
    end
    
    the_steps
  end
  
end

class Expression::Det
  
  def steps
    
    the_steps = []
    value     = @val.simplify
    dim       = value.val.dim()
    
    the_steps << Steps["Find the determinant of a matrix.", value.display, nil]
    
    case dim
    when Dimension.new(0,0)
      the_steps << Steps["The determinant of an empty matrix is 1.", "1", nil]
    when Dimension.new(1,1)
      the_steps << Steps["The determinant of a 1x1 matrix is its element", "#{value.val[0,0]}", nil]
    else
      row = value.val.rows[0]
      
      the_steps << Steps["Select a row or column (1st row chosen)", Matrix[ row ].display, nil]
      the_steps << Steps["For each element in the row/column, find its cofactor", nil, nil]
      
      cofactors = value.val.cofactors.rows[0].map &:simplify
      
      cofactors.each_with_index do |cofactor,i|
        the_steps << Steps["Element #{i+1}", cofactor.display, value.cofactors.steps ]
      end
      
      determinant = row.zip(cofactors).map{ |e| (e[0]*e[1]).display }.join("+")
      
      the_steps << Steps["Multiply each element with its cofactor, and sum them together.", determinant, nil ]
      
      the_steps << Steps[nil, "= " << row.zip(cofactors).map{ |e| e[0]*e[1] }.inject(0, &:+).simplify.display, nil]
      
    end
    
    the_steps
  end
  
end

class Expression::Cofactors
  
  def steps
    
    the_steps = []
    value     = @val.simplify
    
    the_steps << Steps["Finding the cofactor of an element in a matrix.", value.display ]
    the_steps << Steps["For example, the element [1,1], top left."]
    
    minor     = Expression.new value.val.without_row(1).without_col(1)
    minor_det = minor.det
    
    the_steps << Steps["Firstly, create a new matrix by removing the row and column that the\
                        element in question resides in, this is the Minor matrix.", minor.display]
    
    the_steps << Steps["Find the determinant of the Minor matrix.", minor_det.simplify.display, minor_det.steps]
    
    the_steps << Steps["Multiply the determinant of the minor matrix by (-1)^(i+j) where i and\
                       j are the row and column index (respectively) of the element in the matrix.\
                       In this example, i and j are both 1", (1*minor_det.simplify).display ]
    
    the_steps << Steps[nil, "= " << minor_det.simplify .display ]
    
    
    the_steps
  end
  
end
