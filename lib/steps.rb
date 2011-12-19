Steps = Struct.new(:instructions, :result, :further_steps)

class Expression::UnOp
  
  def steps
    return @val.respond_to?(:steps) ? @val.steps : []
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
    
    value       = @val.simplify
    determinant = value.det.simplify
    
    the_steps << Steps["Invert matrix", value.display, nil]
    
    the_steps << Steps["Calculate the Determinant", determinant, value.det.steps]
    
    the_steps << Steps["If the determinant is 0, The matrix cannot be inverted", nil]
    
    unless determinant == 0
      
      cofactors = value.cofactors.simplify
      inverted  = ((1.0/determinant)*cofactors).simplify
      
      the_steps << Steps["Calculate the cofactors matrix", cofactors.display, value.cofactors.steps]
      the_steps << Steps["Multiply the reciprocal of the determinant with the cofactors matrix", inverted.display, nil]
    end
    
    the_steps
  end
  
end

class Expression::Det
  
  def steps
    
  end
  
end

