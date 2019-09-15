class CreateWorkDays < ActiveRecord::Migration[5.2]
  def change
    create_table :work_days do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :employee_id

      t.timestamps
    end
  end
end
