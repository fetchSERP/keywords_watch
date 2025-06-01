class AddTechnicalInfosDomain < ActiveRecord::Migration[8.0]
  def change
    add_column :domains, :infos, :jsonb, default: {}
  end
end
