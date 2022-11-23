class AdminsController < ApplicationController
  before_action :require_admin

  def show
    @users = User.order(created_at: :desc).page(params[:page])
  end

  def find_users
    @users = User.order(created_at: :desc)

    if params[:name].present?
      by_name = "%" + params[:name].gsub(/[,@]/, "") + "%"
      @users = @users.where("complete_name ILIKE ? OR github ILIKE ? OR twitter ILIKE ?", by_name, by_name, by_name)
    end

    @users = @users.reviewers if params[:reviewer].presence == "1"
    @users = @users.editors if params[:editor].presence == "1"
    @users = @users.admins if params[:admin].presence == "1"

    @users = @users.distinct.page(params[:page])

    render template: 'admins/show'
  end
end
