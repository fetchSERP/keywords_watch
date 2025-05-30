class CreateDomainCompetitors < ActiveRecord::Migration[8.0]
  def change
    create_table :domain_competitors do |t|
      t.references :user, null: false, foreign_key: true
      t.references :domain, null: false, foreign_key: true
      t.string :competitor_domain
      t.integer :serp_appearances_count, default: 0
      t.string :keyword_ids, array: true, default: []

      t.timestamps
    end
  end
end
