class CreateSeoKeywords < ActiveRecord::Migration[8.0]
  def change
    create_table :seo_keywords do |t|
      t.string :name
      t.boolean :is_long_tail, default: false
      t.references :seo_keyword, null: true, foreign_key: true
      t.integer :search_intent, default: 0
      t.string :competition
      t.string :search_volume
      t.string :avg_monthly_searches

      t.timestamps
    end
    add_index :seo_keywords, :name, unique: true
  end
end
