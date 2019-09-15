class AddTypeOfTaskToTask < ActiveRecord::Migration[5.2]
  def change
		add_column :tasks, :type_of_task, :string
  end
end
