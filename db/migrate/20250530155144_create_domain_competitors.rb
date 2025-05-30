class CreateDomainCompetitors < ActiveRecord::Migration[8.0]
  def change
    create_table :competitors do |t|
      t.references :user, null: false, foreign_key: true
      t.references :domain, null: false, foreign_key: true
      t.string :domain_name
      t.integer :serp_appearances_count, default: 0

      t.timestamps
    end
  end
end
