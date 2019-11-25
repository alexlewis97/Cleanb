class AddTempClusterToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :temp_cluster, :string
  end
end
