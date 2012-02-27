module CalculateHelper

  def is_numeric x
    /^\-?\d+(?:\.\d+)?$/ =~ x
  end
  
  def parse_element x
    c = Calculation.new
    if c.parse(x)
      return c.subd_calc.simplify
    else
      return nil
    end
  end
  
  def unparse_element x
    x_str = x.to_s
    
    x_str.gsub!(/\^/, "**")
    
    pattern = Regexp.union( 
    /[a-z\)]\d+(?:\.\d+)?[a-z\(]/ , 
    /[a-z\)][\d\(]/ , 
    /[\d\)][a-z]/ )
    
    x_str.gsub!( pattern ) do |chars|
      chars.split("").join("*")
    end
    
    x_str.gsub!(/[a-z]+/){ |c| c.split("").join("*") }
    
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
  
  def display_step step

      step_string = "" 

      step_string << "<div class=\\'instruction\\'>"
      step_string << step.instructions                         if step.instructions
      step_string << " <a class=\\'show-step\\'>Show Further Steps</a>" if step.further_steps && step.further_steps != []
      step_string << "</div>"

      if step.result
        step_string << "<div class=\\'answer\\'>"
        step_string << "<pre>#{step.result.gsub(/\n/, '<br/>')}</pre>"
        step_string << "</div>"
      end

      if step.further_steps && step.further_steps != []
        step_string << "<div class=\\'further-step\\'>"
        step_string << step.further_steps.map { |step| display_step(step) }.join("")
        step_string << "</div>"
      end

      step_string
    end
  
  def validate_state_file contents
    return false if /^(?:.*\n){52}$/ !~ contents
    contents.split("\n")[0...26].map { |x| x == "" || !(is_numeric x).nil? }.inject(true) { |t,b| t && b }
  end
  
end
