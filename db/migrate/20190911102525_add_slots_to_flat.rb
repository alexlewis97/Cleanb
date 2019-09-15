class AddSlotsToFlat < ActiveRecord::Migration[5.2]
  def change
    add_column :flats, :slots, :integer
  end
end
