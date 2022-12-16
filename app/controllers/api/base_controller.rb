class Api::BaseController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :verify_token

  def verify_token
    head(:unauthorized) unless valid_token?(params["token"]) || valid_token?(request.headers["TOKEN"])
  end


  private

  def valid_token?(token)
    return false if token.blank? || reviewers_api_token.blank?
    reviewers_api_token == token
  end

  def reviewers_api_token
    @reviewers_api_token ||= ENV["REVIEWERS_API_TOKEN"]
  end
  helper_method :reviewers_api_token

  def record_not_found
    head :not_found
  end

end

