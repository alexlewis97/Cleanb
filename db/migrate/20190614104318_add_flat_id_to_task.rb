class AddFlatIdToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :flat_id, :integer
  end
end
