class UsersController < ApplicationController
  before_action :require_admin

  def show
    @user = User.includes(:languages, :areas).find(params[:id])
    @feedbacks = @user.feedbacks.includes(:editor).page(params[:page])
  end
end
