class RemoveFullnameFromUsers < ActiveRecord::Migration[6.0]
  def change

    remove_column :users, :Fullname, :string
  end
end
