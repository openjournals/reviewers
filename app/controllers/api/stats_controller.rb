class Api::StatsController < Api::BaseController
  before_action :validate_params
  before_action :load_user_and_stats
  before_action :discard_repeated_actions

  NEW_ASSIGNMENT_ACTIONS = ["review_started", "review_assigned"].freeze
  NEW_UNASSIGNMENT_ACTIONS = ["review_unassigned", "review_finished"].freeze
  VALID_ACTIONS = NEW_ASSIGNMENT_ACTIONS + NEW_UNASSIGNMENT_ACTIONS

  def update
    if NEW_ASSIGNMENT_ACTIONS.include?(params[:what])
      @user_stats.active_reviews += 1
      @user_stats.reviews_all_time += 1
    elsif NEW_UNASSIGNMENT_ACTIONS.include?(params[:what])
      @user_stats.active_reviews -= 1 unless @user_stats.active_reviews == 0
      @user_stats.last_review_on = Time.now
    end
    @user_stats.save
  end

  private

  def validate_params
    render plain: "Invalid param: action", status: :unprocessable_entity unless VALID_ACTIONS.include?(params[:what])
  end

  def load_user_and_stats
    github_handle = params[:username].sub("@", "")
    @user = User.includes(:stat).find_by! github: github_handle
    @user_stats = @user.stat
  end

  def discard_repeated_actions
    if params["idempotent_key"].present?
      if params["idempotent_key"] == @user_stats.last_action_key
        head :bad_request
      else
        @user_stats.last_action_key = params["idempotent_key"]
      end
    end
  end
end
