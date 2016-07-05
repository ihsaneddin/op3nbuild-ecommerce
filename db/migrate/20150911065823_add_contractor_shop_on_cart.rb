class AddContractorShopOnCart < ActiveRecord::Migration
  def change
    add_column :carts, :contractor_id, :integer, index: true
  end
end
