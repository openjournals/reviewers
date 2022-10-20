class ReviewersController < ApplicationController
  before_action :require_editor

  def index
    @reviewers = User.reviewers
  end
end
