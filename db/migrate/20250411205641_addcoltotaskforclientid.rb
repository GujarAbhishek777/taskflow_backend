class Addcoltotaskforclientid < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :client_id, :integer
  end
end
