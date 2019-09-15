class AddInfoToEmployee < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :name, :string
    add_column :employees, :schedule, :array
  end
end
