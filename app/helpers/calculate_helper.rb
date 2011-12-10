module CalculateHelper

  def is_numeric x
    /^\d+(?:\.\d+)?$/ =~ x
  end

end
