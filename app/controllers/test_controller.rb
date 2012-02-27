class TestController < ApplicationController
  
  before_filter :check_method, :except => :setup
  
  def check_method
    if request.get?
      redirect_to test_setup_path and return
    end
  end
  
  def setup
    
    respond_to do |format|
      format.html
    end
    
  end

  def test
    
      if params[:_topics] == ""
        flash[:type] = "error"
        flash[:msg]  = "No topics chosen for test!"
        
        redirect_to test_setup_path and return
      end
      
      @topics = params[:_topics].chomp.split " "
      @topic  = @topics.sample
      
      @question = Question.new(@topic, params[:_type])
      
      case params[:_type]
      when "Multiple-Choice"
        test_template = "mc.html.erb"
        @answer       = @question.random_sub(:a)
      when "Free-Form"
        test_template = "ff.html.erb"
      end
      
      @answer ||= @question.ans
      
      @answer = case @answer
      when Matrix
        Matrix[ *@answer.map(&:to_i).rows ]
      when Numeric
        @answer.to_i
      end
      
      @type = params[:_type]
      
      respond_to do |format|
        format.html { render test_template }
      end
    
  end

end