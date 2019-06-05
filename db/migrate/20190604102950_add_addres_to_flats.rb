class AddAddresToFlats < ActiveRecord::Migration[5.2]
  def change
		add_column :flats, :address, :string
		add_column :flats, :created_at, :datetime
		add_column :flats, :updated_at, :datetime
  end
end
