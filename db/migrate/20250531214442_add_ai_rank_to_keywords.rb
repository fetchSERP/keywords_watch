class AddAiRankToKeywords < ActiveRecord::Migration[8.0]
  def change
    add_column :keywords, :ai_score, :integer#, default: 0
  end
end
