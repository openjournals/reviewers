class User < ApplicationRecord
  has_and_belongs_to_many :languages
  has_and_belongs_to_many :areas

  validates :github, uniqueness: true
  validates :github_uid, uniqueness: true, allow_nil: true

  before_save :clean_twitter_username

  scope :reviewers, -> { where(reviewer: true) }

  def self.from_github_omniauth(auth)
    # TODO: Include never logged in users: where(email: auth.info.email, github_uid: nil).first
    where(github_uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.github = auth.info.nickname
      user.github_avatar_url = auth.info.image
      user.github_token = auth.credentials.token
      user.reviewer = true
      user.save
    end
  end

  def avatar
    github_avatar_url || "default_avatar.png"
  end

  def screen_name
    complete_name.present? ? complete_name : "@" + github
  end

  private

  def clean_twitter_username
    self.twitter = self.twitter.gsub(/https?:\/\//, "").gsub(/(www.)?twitter.com\//, "").gsub("@", "") if self.twitter.present?
  end
end
