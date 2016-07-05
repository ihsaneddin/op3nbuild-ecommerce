class AddRoleToComments < ActiveRecord::Migration
  def change
  	add_column :comments, :role, :string, default: 'comments'
  	add_column :comments, :type, :string
  end
end
