class AddAnalysisStatusToDomains < ActiveRecord::Migration[8.0]
  def change
    add_column :domains, :analysis_status, :jsonb, default: {}
  end
end
