module CalculateHelper

  def is_numeric x
    /^\d+(?:\.\d+)?$/ =~ x
  end
  
  def parse_element x
    c = Calculation.new
    if c.parse(x)
      return c.calculate
    else
      return nil
    end
  end
  
  def unparse_element x
    x_str = x.to_s
    
    x_str.gsub!(/\^/, "**")
    x_str.gsub!(/[a-z]+/) do |chars|
      chars.split("").join("*")
    end
    
    x_str
  end
  
  def resize_mat mat, d
    return nil if mat.nil?
    
    rows = []
    
    d.y.times { rows << [] }
    
    d.y.times do |j|
    d.x.times do |i|
    
      rows[j][i] = (mat[i,j] ? mat[i,j] : 0) rescue 0
        
    end
    end
    
    return Matrix[ *rows ]
  end

end
