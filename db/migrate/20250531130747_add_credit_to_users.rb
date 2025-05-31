class AddCreditToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :credit, :integer
  end
end
