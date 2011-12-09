class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :check_session

  def check_session
    session[:calc] ||= Calculation.new
    @calculation = session[:calc]
  end

end
