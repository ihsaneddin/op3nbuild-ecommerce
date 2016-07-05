class CreateRequestsRefunds < ActiveRecord::Migration
  def self.up
    create_table :requests_refunds do |t|
    	t.decimal :amount,  :default => 0.0, :precision => 8, :scale => 2
    	t.string :state
    	t.string :reason
    	t.text :note, null: false
    	t.integer :order_id
      t.integer :transaction_id
      t.timestamps null: false
    end
    add_index :requests_refunds, :order_id
    add_index :requests_refunds, :transaction_id
  end

  def self.down
    drop_table :requests_refunds  
  end
end
