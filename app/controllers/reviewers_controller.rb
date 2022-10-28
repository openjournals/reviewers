class ReviewersController < ApplicationController
  before_action :require_editor

  def index
    @reviewers = User.reviewers.includes(:languages, :areas).order(created_at: :desc).limit(25)
  end

  def show
    @reviewer = User.includes(:languages, :areas).find(params[:id])
  end

  def search
    @reviewers = User.reviewers.includes(:languages, :areas)

    if params[:area].present?
      @reviewers = @reviewers.left_joins(:areas).where(areas: [params[:area]])
    end

    if params[:language].present?
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

    @reviewers = @reviewers.distinct.order(created_at: :desc).limit(25)

    respond_to do |format|
      format.json
      format.html { render template: 'reviewers/index' }
    end
  end
end
