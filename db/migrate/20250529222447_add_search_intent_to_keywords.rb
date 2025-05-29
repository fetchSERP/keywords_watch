class AddSearchIntentToKeywords < ActiveRecord::Migration[8.0]
  def change
    add_column :keywords, :search_intent, :integer
  end
end
