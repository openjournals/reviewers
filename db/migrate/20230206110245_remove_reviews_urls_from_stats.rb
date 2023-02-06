class RemoveReviewsUrlsFromStats < ActiveRecord::Migration[7.0]
  def change
    remove_column :stats, :reviews_url, :string, default: ""
    remove_column :stats, :active_reviews_url, :string, default: ""
  end
end
