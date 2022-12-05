class RefactorStats < ActiveRecord::Migration[7.0]
  def change
    remove_column :stats, :reviews_last_year, :integer, default: 0
    remove_column :stats, :reviews_last_quarter, :integer, default: 0

    add_column :stats, :last_review_on, :date

    rename_column :stats, :reviews_url_template, :reviews_url
    rename_column :stats, :active_reviews_url_template, :active_reviews_url
  end
end
