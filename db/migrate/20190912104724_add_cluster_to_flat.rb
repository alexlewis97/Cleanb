class AddClusterToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :cluster, :integer
  end
end
