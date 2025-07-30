class AddTrackedKeywordsCountToDomains < ActiveRecord::Migration[8.0]
  def change
    add_column :domains, :tracked_keywords_count, :integer, default: 10
  end
end
