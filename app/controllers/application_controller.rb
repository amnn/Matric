class ApplicationController < ActionController::Base
  protect_from_forgery

  around_filter :wrap_sync
  before_filter :clear_flash_msg


  def wrap_sync
    sync_session
    yield
    sync_session
  end

  def sync_session
    @calc ||= session[:calc] || Calculation.new
    session[:calc] = @calc
  end

  def clear_flash_msg
    flash[:msg]  = nil
    flash[:type] = nil
  end

end
