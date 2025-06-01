class CreateWebPages < ActiveRecord::Migration[8.0]
  def change
    create_table :web_pages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :domain, null: false, foreign_key: true
      t.string :url
      t.string :title
      t.string :meta_description
      t.string :meta_keywords, array: true, default: []
      t.text :h1, array: true, default: []
      t.text :h2, array: true, default: []
      t.text :h3, array: true, default: []
      t.text :h4, array: true, default: []
      t.text :h5, array: true, default: []
      t.text :body
      t.integer :word_count
      t.string :internal_links, array: true, default: []
      t.string :external_links, array: true, default: []
      t.string :canonical_url
      t.boolean :indexed
      t.text :html

      t.timestamps
    end
  end
end
