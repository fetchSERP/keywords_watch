class AddIndexedAndUrlsToKeywords < ActiveRecord::Migration[8.0]
  def change
    add_column :keywords, :indexed, :boolean, default: false
    add_column :keywords, :urls, :string, array: true, default: []
  end
end
