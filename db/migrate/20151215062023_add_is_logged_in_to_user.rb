class AddIsLoggedInToUser < ActiveRecord::Migration
  def change
  	add_column :users, :is_logged_in, :boolean, default: false
  end
end
