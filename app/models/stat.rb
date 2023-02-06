class Stat < ApplicationRecord
  belongs_to :user

  def all_reviews_url
    Rails.configuration.reviewers_settings["all_reviews_url_template"].to_s.gsub("{{github}}", user.github)
  end

  def active_reviews_url
    Rails.configuration.reviewers_settings["active_reviews_url_template"].to_s.gsub("{{github}}", user.github)
  end

end
