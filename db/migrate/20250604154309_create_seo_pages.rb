class CreateSeoPages < ActiveRecord::Migration[8.0]
  def change
    create_table :seo_pages do |t|
      t.references :seo_keyword, null: false, foreign_key: true
      t.string :slug
      t.string :title
      t.text :meta_description
      t.text :headline
      t.text :subheading
      t.text :content
      t.references :seo_page, null: true, foreign_key: true

      t.timestamps
    end
    add_index :seo_pages, :slug, unique: true
  end
end
