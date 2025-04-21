class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.string :content
      t.integer :senderId
      t.integer :receiverId
      t.integer :client_id
      t.timestamps
    end
  end
end
