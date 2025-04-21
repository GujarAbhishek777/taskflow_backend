class Addcreatortouser < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :creator, :integer
  end
end
