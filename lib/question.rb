class Question

  OperData = Struct.new(:count, :method, :size, :limit)
  
  attr_reader :operands, :op, :type, :ans
  
  def initialize subject, type

    case subject
    when "Addition"
      @op      = :+
      operdata = OperData[2, :random, 2+rand(2), 5]
    when "Subtraction"
      @op      = :-
      operdata = OperData[2, :random, 2+rand(2), 5]
    when "Multiplication"
      @op      = :*
      operdata = OperData[2, :random, 2+rand(2), 5]
    when "Determinants"
      @op      = :det
      operdata = OperData[1, :random, 2+rand(2), 5]
    when "Inverse"
      @op      = :inverse
      operdata = OperData[1, :nice, 2+rand(2), 5]
    end
    
    @operands = [] 
    operdata.count.times { @operands << Matrix.send( operdata.method, operdata.size, operdata.limit ) }
    
    first, *rest = *@operands
    
    unless rest == []
      @ans = rest.inject(first, &@op )
    else
      @ans = first.send(@op)
    end
    
    @type = type
    
  end
  
  def random_sub sym
    
    return nil if !(Matrix === ans)
    
    var = Expression.new sym
    
    rows = @ans.rows
    dim  = @ans.dim
    x    = rand(dim.x)
    y    = rand(dim.y)
    
    val  = rows[y][x]
    rows[y][x] = var
    
    @ans = Matrix[ *rows ]
    
    return val
  end
  
end