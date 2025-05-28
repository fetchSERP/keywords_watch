class CreateKeywords < ActiveRecord::Migration[8.0]
  def change
    create_table :keywords do |t|
      t.string :name
      t.integer :avg_monthly_searches
      t.string :competition
      t.integer :competition_index
      t.integer :low_top_of_page_bid_micros
      t.integer :high_top_of_page_bid_micros
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
