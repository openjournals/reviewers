class ClearInvalidUserUrls < ActiveRecord::Migration[7.2]
  def up
    execute(<<~SQL)
      UPDATE users
      SET url = NULL
      WHERE url IS NOT NULL
        AND url <> ''
        AND url !~* '^https?://'
    SQL
  end

  def down
    # Cleared values are not recoverable.
  end
end
