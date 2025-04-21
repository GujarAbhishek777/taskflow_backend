class Addcolumntouser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :client_name, :string
    add_column :users, :client_id, :integer
  end
end
