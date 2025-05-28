class CreateRankings < ActiveRecord::Migration[8.0]
  def change
    create_table :rankings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :domain, null: false, foreign_key: true
      t.references :keyword, null: false, foreign_key: true
      t.integer :rank
      t.string :search_engine
      t.string :url
      t.string :country

      t.timestamps
    end
  end
end
