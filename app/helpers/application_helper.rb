module ApplicationHelper

  def flash_class_for(flash_level)
    case flash_level
    when 'error'
      'alert-danger'
    when 'warning'
      'alert-warning'
    when 'notice'
      'alert-primary'
    else
      'alert-primary'
    end
  end

  def github_link(github_handle, link_text=nil)
    return "Anonymous" if github_handle.blank?
    text = link_text || github_handle
    link_to(text, "https://github.com/" + github_handle, target: "_blank", title: "View GitHub page for #{github_handle}")
  end

  def orcid_link(orcid_code, link_text=nil)
    return "No ORCID" if orcid_code.blank?
    text = link_text || orcid_code
    link_to(text, "https://orcid.org/" + orcid_code, target: "_blank", title: "View reviewer's ORCID page")
  end

  def bg_by_rating(rating)
    if rating == "positive"
      "bg-green-50"
    elsif rating == "negative"
      "bg-red-50"
    elsif rating == "neutral"
      "bg-yellow-50"
    end
  end

  def bg_by_score(score, total_feedbacks = 0)
    if score > 0
      "bg-green-50"
    elsif score < 0
      "bg-red-50"
    elsif total_feedbacks != 0
      "bg-yellow-50"
    end
  end

  def journal_name
    ENV["JOURNAL_NAME"] || Rails.configuration.reviewers_settings[:journal][:name]
  end

  def journal_alias
    ENV["JOURNAL_ALIAS"] || Rails.configuration.reviewers_settings[:journal][:alias]
  end

  def journal_url
    ENV["JOURNAL_URL"] || Rails.configuration.reviewers_settings[:journal][:url]
  end
end
