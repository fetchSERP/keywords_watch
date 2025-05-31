class AddIsTrackedToKeywords < ActiveRecord::Migration[8.0]
  def change
    add_column :keywords, :is_tracked, :boolean, default: false
  end
end
