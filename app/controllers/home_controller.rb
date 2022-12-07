class HomeController < ApplicationController
  def index
    if current_user
      render :user_home
    else
      render :public_home
    end
  end

  def reviewer_signup
    redirect_to root_path if current_user
  end
end
