class SingularMatrixError < ZeroDivisionError
  attr :mat
  
  def initialize mat
    @mat = mat
  end
  
end