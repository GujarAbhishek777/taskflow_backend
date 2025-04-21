class Addcoltouserastaskcreator < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :task_creator, :boolean, default:false
  end
end
