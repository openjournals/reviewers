class UsersController < ApplicationController
  before_action :require_admin
  before_action :load_user, only: [:edit, :update, :status, :destroy]

  def show
    @user = User.includes(:languages, :areas).find(params[:id])
    @feedbacks = @user.feedbacks.includes(:editor).page(params[:page])
  end

  def edit
  end

  def update
    if @user.update(user_update_params)
      redirect_to user_path(@user), notice: "User data updated!"
    else
      render action: :edit, status: :unprocessable_entity
    end
  end

  def status
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

  def user_update_params
    params.require(:user).permit(:github, :complete_name, :citation_name, :email, :affiliation, { area_ids: [], language_ids: [] }, :domains, :url, :description)
  end
end
