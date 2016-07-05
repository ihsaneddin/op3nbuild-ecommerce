class CreateRequestsBalances < ActiveRecord::Migration
  def self.up
    create_table :requests_balances do |t|
    	t.decimal :amount,  :default => 0.0, :precision => 8, :scale => 2
      t.integer :user_id, null: false
      t.timestamps null: false
    end
    add_index :requests_balances, :user_id
  end

  def self.down
  	drop_table :requests_balances
  end
end
