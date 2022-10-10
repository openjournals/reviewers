class User < ApplicationRecord
  has_and_belongs_to_many :languages
  has_and_belongs_to_many :areas

  validates :github, uniqueness: true
  validates :github_uid, uniqueness: true
  validates :email, presence: true

  before_save :clean_twitter_username

  def self.from_github_omniauth(auth)
    where(github_uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.github = auth.info.nickname
      user.github_avatar_url = auth.info.image
      user.github_token = auth.credentials.token
      user.save
    end
  end

  private

  def clean_twitter_username
    self.twitter = self.twitter.gsub(/https?:\/\//, "").gsub(/(www.)?twitter.com\//, "").gsub("@", "")
  end
end
