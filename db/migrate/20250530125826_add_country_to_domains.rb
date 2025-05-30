class AddCountryToDomains < ActiveRecord::Migration[8.0]
  def change
    add_column :domains, :country, :string, default: "us"
  end
end
