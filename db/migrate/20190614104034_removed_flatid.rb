class RemovedFlatid < ActiveRecord::Migration[5.2]
  def change
		remove_column :tasks, :flatid, :float
  end
end
