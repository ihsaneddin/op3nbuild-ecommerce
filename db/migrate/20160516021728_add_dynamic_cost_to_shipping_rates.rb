class AddDynamicCostToShippingRates < ActiveRecord::Migration
  def change
  	add_column :shipping_methods, :dynamic_cost, :boolean
  	add_column :order_items, :shipping_cost, :decimal, :default => 0.0, :precision => 8, :scale => 2
  	add_column :shipping_methods, :description, :text
  end
end
