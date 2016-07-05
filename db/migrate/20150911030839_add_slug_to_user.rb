class AddSlugToUser < ActiveRecord::Migration
  def change
    add_column :users, :company_name, :string
    add_column :users, :slug, :string, null: false, index: true
  end
end
