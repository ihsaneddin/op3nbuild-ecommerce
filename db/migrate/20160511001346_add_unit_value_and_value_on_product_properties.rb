class AddUnitValueAndValueOnProductProperties < ActiveRecord::Migration
  def change
  	add_column :product_properties, :value, :float
  	add_column :product_properties, :unit_value, :string
  	add_column :properties, :units, :string
  end
end
