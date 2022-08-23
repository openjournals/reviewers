class HomeController < ApplicationController
  def index
    if current_user
      render :user_home
    else
      render :public_home
    end
  end
end
