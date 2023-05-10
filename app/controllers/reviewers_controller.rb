class ReviewersController < ApplicationController
  before_action :require_user

  def index
    @reviewers = User.reviewers.includes(:languages, :areas, :stat).order(order_by).page(params[:page])
  end

  def show
    @reviewer = User.includes(:languages, :areas, :stat).find(params[:id])
    @feedbacks = @reviewer.feedbacks.includes(:editor).page(params[:page]) if current_editor
  end

  def search
    @reviewers = User.reviewers.includes(:languages, :areas, :stat)

    if params[:area_id].present?
      @area = Area.find(params[:area_id])
      @reviewers = @reviewers.left_joins(:areas).where(areas: [params[:area_id]])
    end

    if params[:language].present?
      @language = Language.find(params[:language])
      @reviewers = @reviewers.left_joins(:languages).where(languages: [params[:language]])
    end

    if params[:name].present?
      by_name = "%" + params[:name].gsub(/[,@]/, "") + "%"
      @reviewers = @reviewers.where("complete_name ILIKE ? OR github ILIKE ? OR twitter ILIKE ?", by_name, by_name, by_name)
    end

    if params[:keywords].present?
      by_keywords = params[:keywords].split(",").map(&:strip).select{ |k| !k.empty? }.map{ |k| "%#{k}%" }
      unless by_keywords.empty?
        binded_keywords, conditions = [], []
        by_keywords.each do |k|
          conditions << "(description ILIKE ? OR domains ILIKE ?)"
          binded_keywords += [k, k]
        end
        @reviewers = @reviewers.where(conditions.join(" AND "), *binded_keywords )
      end
    end

    @reviewers = @reviewers.distinct.order(order_by).page(params[:page])

    respond_to do |format|
      format.json
      format.html { render template: 'reviewers/index' }
    end
  end

  private
  def order_by
    order_direction = params[:direction].presence == "asc" ? :asc : :desc
    if params[:sort].presence == "load"
      "stats.active_reviews #{order_direction.to_s.upcase}, users.feedback_score_last_3 DESC, users.updated_at DESC"
    elsif params[:sort].presence == "score"
      { feedback_score_last_3: order_direction, feedback_score: order_direction, feedbacks_count: order_direction }
    else
      { github: :asc }
    end
  end
end
