class CreateWorkTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :work_tasks do |t|
      t.integer :work_day_id
      t.integer :task_id
      t.boolean :finished

      t.timestamps
    end
  end
end
