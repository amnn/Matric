class ApplicationController < ActionController::Base
  protect_from_forgery

  around_filter :wrap_sync

  def wrap_sync
    sync_session
    yield
    sync_session
  end

  def sync_session
    @calc ||= session[:calc] || Calculation.new
    session[:calc] = @calc
  end

end
