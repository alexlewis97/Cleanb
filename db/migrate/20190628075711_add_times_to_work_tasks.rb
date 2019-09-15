class AddTimesToWorkTasks < ActiveRecord::Migration[5.2]
  def change
		add_column :work_tasks, :start_time, :datetime
		add_column :work_tasks, :end_time, :datetime
  end
end
