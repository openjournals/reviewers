class FeedbacksController < ApplicationController
  before_action :require_editor

  def create
    @feedback = current_editor.given_feedbacks.build(feedback_params)

    if @feedback.save
      flash[:notice] = "Feedback saved!"
    else
      flash[:error] = "Comment can't be empty for neutral feedback"
    end

    redirect_to reviewer_path(feedback_params[:user_id])
  end

  def destroy
    feedback = current_editor.given_feedbacks.find(params[:id])
    reviewer_id = feedback.user_id
    feedback.destroy
    redirect_to reviewer_path(reviewer_id), notice: "Feedback deleted"
  end


  private

  def feedback_params
    params.require(:feedback).permit(:rating, :comment, :link, :user_id)
  end
end
