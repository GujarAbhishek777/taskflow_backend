class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :description
      t.string :user_name
      t.integer :user_id
      t.date :due_date
      t.integer :status_value
      t.string :status
      t.timestamps
    end
  end
end
