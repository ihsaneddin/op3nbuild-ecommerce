class CreateMarketPlaces < ActiveRecord::Migration
  def change
    create_table :market_places do |t|
      t.string :name, null: false
      t.string :title, null: false
      t.string :sub_title
      t.text :description
      t.references :contractor, index: true
      t.timestamps null: false
    end
  end
end
