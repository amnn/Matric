class CalculateController < ApplicationController
  include CalculateHelper

  def index
    
    flash[:msg] = ""
    
    case params[:commit]
    when "Calculate"
      if @calc.parse(params[:calc])
        flash[:msg] << "Parse Succesful! ... "
        flash[:type] = "notice"
        
        begin
          @final_expr = @calc.calculate
          append = "Calculation Succesful!"
        rescue => $error
          append = "Calculation failed!"
          flash[:type] = "error"
        end
        
        flash[:msg] << append
      else
        
        flash[:msg] << "Parse Failure! ... "
        flash[:type] = "error"
      end
    end
    
    respond_to do |format|
      format.html
      format.js { render "calculation.js.coffee.erb" }
    end
  end

  def matrix
    @mat = params[:id]

    @verb = params[:commit]

    case @verb
    when "Save"
      if params[:_dim_x] && params[:_dim_y]
        d = Dimension.new(params[:_dim_x].to_i, params[:_dim_y].to_i)
        
        rows = []
        d.y.times { rows << [] }
        
        d.y.times do |j|
        d.x.times do |i|
          if (elem = parse_element(params["val-#{i},#{j}".to_sym]))
            rows[j][i] = elem
          else
            flash[:msg] = "Save Failed!"
            flash[:type] = "error"
          end
        end
        end
        
        @calc.add_matrix @mat, *rows unless flash[:type] == "error"
        
        flash[:msg] ||= "Save Succesful!"
        flash[:type] ||= "notice"
        
      end
    when "Clear"
      
      logger.debug @mat.class
      
      @calc.clear_matrix @mat
      
      flash[:msg] = "Clear Succesful!"
      flash[:type] = "notice"
      
      d = Dimension.new(params[:_dim_x].to_i, params[:_dim_y].to_i)
      rows = []
      d.y.times { rows << [""]*d.y }
      mat = Matrix[ *rows ]
      
    when "Confirm" # Dimension change
      @d = Dimension.new(params[:dim_x].to_i, params[:dim_y].to_i)
    end

    mat ||= @calc.mats[@mat.to_sym] ? @calc.mats[@mat.to_sym].val : nil
    d   ||= @calc.mats[@mat.to_sym] ? mat.dim : Dimension.new(0,0)
    
    @fields = {}
    @type = "mat"
    
    d.y.times do |j|
    d.x.times do |i|
      @fields["field-#{i}_#{j}"] = mat[i,j] rescue ""
    end
    end
    
    if @calc.mats[@mat.to_sym]
      @d ||= @calc.mats[@mat.to_sym].val.dim
    else
      @d ||= Dimension.new(2,2)
    end

    @mat_val = @calc.mats[@mat.to_sym] ? resize_mat(@calc.mats[@mat.to_sym].val, @d) : nil

    respond_to do |format|
      format.html
      format.js { render "update_sym.js.coffee.erb" }
    end
  end


  def var
    @var = params[:id]

    @verb = params[:commit]

    case @verb
    when "Save"
      if params[:val] && is_numeric(params[:val])
        v = params[:val]
        val = v.to_f == v.to_i ? v.to_i : v.to_f
        @calc.add_var @var, val

        flash[:msg]  = "Save Succesful!"
        flash[:type] = "notice"
      else

        flash[:msg]  = "Save Failed!"
        flash[:type] = "error"
      end
    when "Clear"
      @calc.clear_var @var

      flash[:msg]  = "Clear Succesful!"
      flash[:type] = "notice"
    end

    @fields = Hash["field-1", @calc.vars[@var.to_sym]]
    @type = "var"

    respond_to do |format|
      format.html
      format.js { render "update_sym.js.coffee.erb" }
    end
  end

  def save

    respond_to do |format|
      format.text do
        t = Time.now

        send_data @calc.save_state, 
                  :filename => "matric-state-#{t.strftime('%d%m%y')}.txt"

        return
      end
    end
  end

end
