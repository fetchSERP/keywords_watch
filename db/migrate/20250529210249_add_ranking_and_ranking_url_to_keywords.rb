class AddRankingAndRankingUrlToKeywords < ActiveRecord::Migration[8.0]
  def change
    add_column :keywords, :ranking, :integer
    add_column :keywords, :ranking_url, :string
  end
end
