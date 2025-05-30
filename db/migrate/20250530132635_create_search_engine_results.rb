class CreateSearchEngineResults < ActiveRecord::Migration[8.0]
  def change
    create_table :search_engine_results do |t|
      t.references :user, null: false, foreign_key: true
      t.references :keyword, null: false, foreign_key: true
      t.string :site_name
      t.string :url
      t.string :title
      t.text :description
      t.integer :ranking
      t.string :search_engine

      t.timestamps
    end
  end
end
