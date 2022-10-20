class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def require_user
    unless current_user
      flash[:error] = "Please login first"
      redirect_back fallback_location: :root
      false
    end
  end

  def require_editor
    unless current_editor
      redirect_to :root
      false
    end
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def current_editor
    if current_user && current_user.editor?
      @current_editor = current_user
    else
      @current_editor = nil
    end
  end
  helper_method :current_editor

  def record_not_found
    render plain: "404 Not Found", status: 404
  end
end
