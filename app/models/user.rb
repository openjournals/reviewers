class User < ApplicationRecord
  has_and_belongs_to_many :languages
  has_and_belongs_to_many :areas
  has_many :feedbacks, dependent: :destroy
  has_many :given_feedbacks, class_name: "Feedback", inverse_of: :editor, foreign_key: :editor_id
  has_one :stat, dependent: :destroy

  validates :github, uniqueness: true, presence: true
  validates :github_uid, uniqueness: true, allow_nil: true

  before_validation :clean_github_username
  after_create :initialize_stats

  scope :reviewers, -> { where(reviewer: true) }
  scope :editors, -> { where(editor: true) }
  scope :admins, -> { where(admin: true) }

  def self.from_github_omniauth(auth, params={})
    user_data = { github_uid: auth.uid,
                  email: auth.info.email,
                  github: auth.info.nickname,
                  github_avatar_url: auth.info.image,
                  github_token: auth.credentials.token }

    if recurring_user = find_by(github_uid: auth.uid)
      user_data.delete(:email) if recurring_user.email.present?
      recurring_user.update(user_data)
      recurring_user
    elsif never_logged_in_user = where(github: auth.info.nickname, github_uid: nil).first
      user_data.merge!({reviewer: true})
      never_logged_in_user.update(user_data)
      never_logged_in_user
    else
      user_data.merge!({reviewer: true}) unless params["reviewer"].presence == "no"
      create(user_data)
    end
  end

  def avatar
    github_avatar_url || "default_avatar.png"
  end

  def screen_name
    complete_name.present? ? complete_name : "@" + github
  end

  def calculate_feedback_scores
    total_score = feedbacks.sum(:rating)
    last_year_score = feedbacks.where("created_at > ?", 12.months.ago).sum(:rating)
    last_3_score = feedbacks_count < 4 ? total_score : feedbacks.where("created_at >= ?", feedbacks.order(created_at: :desc).third.created_at).sum(:rating)

    self.update_columns( feedback_score: total_score,
                         feedback_score_last_3: last_3_score,
                         feedback_score_last_year: last_year_score )
  end

  def initialize_stats
    self.create_stat if self.stat.nil?
  end

  def profile_complete?
    [complete_name, email, affiliation].all? {|data| data.present?} && self.areas.size > 0
  end

  private

  def clean_github_username
    self.github = self.github.strip.gsub("@", "") if self.github.present?
  end
end
