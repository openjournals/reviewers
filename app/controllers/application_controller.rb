class ApplicationController < ActionController::Base

  def require_user
    unless current_user
      flash[:error] = "Please login first"
      redirect_back fallback_location: :root
      false # throw :abort
    end
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
