class AddContractorToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :contractor_id, :integer, null: false, index: true
  end
end
