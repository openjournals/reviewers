class User < ApplicationRecord
  has_and_belongs_to_many :languages

  validates :github, uniqueness: true
  validates :github_uid, uniqueness: true
  validates :email, presence: true

  def self.from_github_omniauth(auth)
    where(github_uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.github = auth.info.nickname
      user.github_avatar_url = auth.info.image
      user.github_token = auth.credentials.token
      user.save
    end
  end
end
