module TestHelper
  
  def topics
    %w(Addition Subtraction Multiplication Determinants Inverse)
  end
  
  def topic_defaults
    %w(Addition Subtraction Multiplication)
  end
  
  def type_default
    "Multiple-Choice"
  end
  
  def types
    %w(Multiple-Choice Free-Form)
  end
  
  def choices_for n, ans
    choices = [ans]
    
    modifiers = [
    lambda { |x| -1*x },
    lambda { |x| (x+1)+rand(10)-5 },
    lambda { |x| rand(10)-5 },
    lambda { |x| (x-1)*(rand(5)+1) },
    lambda { |x| ((x+2)/(rand(5)+1)).to_i } 
    ]
    
    until choices.length == n
      (choices << modifiers.sample[ans]).map!(&:to_i).uniq!
    end
    choices.shuffle
  end
  
end
