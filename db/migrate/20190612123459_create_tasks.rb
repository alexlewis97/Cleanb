class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :type
      t.float :flatid
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :finished

      t.timestamps
    end
  end
end
