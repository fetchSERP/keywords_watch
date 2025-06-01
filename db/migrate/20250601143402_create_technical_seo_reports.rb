class CreateTechnicalSeoReports < ActiveRecord::Migration[8.0]
  def change
    create_table :technical_seo_reports do |t|
      t.jsonb :analysis
      t.references :user, null: false, foreign_key: true
      t.references :web_page, null: false, foreign_key: true
      t.string :url

      t.timestamps
    end
  end
end
