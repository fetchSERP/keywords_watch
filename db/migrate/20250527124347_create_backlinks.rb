class CreateBacklinks < ActiveRecord::Migration[8.0]
  def change
    create_table :backlinks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :domain, null: false, foreign_key: true
      t.string :source_url
      t.string :target_url
      t.string :anchor_text
      t.boolean :nofollow
      t.string :rel_attributes
      t.string :context_text
      t.string :source_domain
      t.string :target_domain
      t.string :page_title
      t.string :meta_description

      t.timestamps
    end
  end
end
