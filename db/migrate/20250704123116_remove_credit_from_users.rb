class RemoveCreditFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :credit, :integer
  end
end
