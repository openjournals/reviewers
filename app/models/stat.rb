class Stat < ApplicationRecord
  belongs_to :user

  def reviews_url
    reviews_url = self.reviews_url_template
    return nil if reviews_url.blank?

    reviews_url = reviews_url.gsub("{{github}}", user.github)
    reviews_url = reviews_url.gsub("{{orcid}}", user.orcid)
    reviews_url = reviews_url.gsub("{{email}}", user.email)

    reviews_url
  end

  def active_reviews_url
    active_reviews_url = self.active_reviews_url_template
    return nil if active_reviews_url.blank?

    active_reviews_url = active_reviews_url.gsub("{{github}}", user.github)
    active_reviews_url = active_reviews_url.gsub("{{orcid}}", user.orcid)
    active_reviews_url = active_reviews_url.gsub("{{email}}", user.email)

    active_reviews_url
  end
end
