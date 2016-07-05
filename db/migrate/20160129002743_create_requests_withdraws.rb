class CreateRequestsWithdraws < ActiveRecord::Migration
  def self.up
    create_table :requests_withdraws do |t|
    	t.decimal :amount,  :default => 0.0, :precision => 8, :scale => 2
    	t.string :state
      t.integer :transaction_id
      t.timestamps null: false
    end
    add_index :requests_withdraws, :transaction_id
  end

  def self.down
  	drop_table :requests_withdraws
  end
end
