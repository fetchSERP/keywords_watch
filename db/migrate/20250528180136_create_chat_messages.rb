class CreateChatMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_messages do |t|
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.string :author

      t.timestamps
    end
  end
end
