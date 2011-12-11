class CalculateController < ApplicationController
  include CalculateHelper

  def index
  end

  def matrix
    @mat = params[:id]

    respond_to do |format|
      format.html
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
