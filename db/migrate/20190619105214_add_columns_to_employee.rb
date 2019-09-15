class AddColumnsToEmployee < ActiveRecord::Migration[5.2]
  def change
		remove_column :employees, :schedule, :array
  end
end
