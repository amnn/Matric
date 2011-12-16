class Expression::UnOp
  
  def steps
    return @val.responds_to?(:steps) ? @val.steps : []
  end
  
end

class Expression::BiOp
  
  def steps
    the_steps = []
    the_steps + @l_oper.steps + @r_oper.steps
    the_steps
  end
  
end

class Expression::Inverse
  
  def steps
    the_steps = []
    
    the_steps << ["Calculate the determinant", @val.det.simplify]
    the_steps << ["If the determinant is 0, The matrix cannot be inverted", nil]
    
    unless the_steps[0][1] == 0
      the_steps << ["Calculate the cofactors matrix", @val.cofactors.simplify ]
      the_steps << ["Multiply the determinant with the cofactors matrix", the_steps[0][1]*the_steps[3][1]]
    end
    
    the_steps
  end
  
end

class Expression::Det
  
  def steps
    
  end
  
end

