class DeleteFinishedFromTask < ActiveRecord::Migration[5.2]
  def change
		remove_column :tasks, :finished
  end
end
