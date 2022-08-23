class SessionsController < ApplicationController
  def create
    user = User.from_github_omniauth(request.env["omniauth.auth"])
    user.update_editor_status

    session[:user_id] = user.id
    if request.env['omniauth.origin']
      redirect_to request.env['omniauth.origin']
    else
      redirect_to root_url
    end
  end

  def auth_failure
    redirect_to root_url, notice: params[:message]
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end

end
