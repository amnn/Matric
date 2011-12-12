module CalculateHelper

  def is_numeric x
    /^\d+(?:\.\d+)?$/ =~ x
  end
  
  def rearrange_mat mat, d
    return [nil, d] if mat.nil?
    
    rows = []
    
    d.y.times { rows << [] }
    
    d.y.times do |j|
    d.x.times do |i|
    
      rows[j][i] = mat[i,j] ? mat[i,j] : 0
      
    end
    end
    
    return [Matrix[ *rows ], d]
  end

end
