class AddContractorToProduct < ActiveRecord::Migration
  def change
    add_column :products, :contractor_id, :integer, null: false, index: true
  end
end
