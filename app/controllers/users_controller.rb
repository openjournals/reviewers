class UsersController < ApplicationController
  before_action :require_admin
  before_action :load_user, only: [:update, :destroy]

  def show
    @user = User.includes(:languages, :areas).find(params[:id])
    @feedbacks = @user.feedbacks.includes(:editor).page(params[:page])
  end

  def update
    @user.update(user_status_params)
    redirect_to user_path(@user), notice: "User status updated!"
  end

  def destroy
    @user.destroy
    redirect_to admin_path, notice: "User deleted"
  end

  private

  def load_user
    @user = User.find(params[:id])
  end

  def user_status_params
    params.permit(:reviewer, :editor, :admin)
  end
end
