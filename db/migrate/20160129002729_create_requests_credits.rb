class CreateRequestsCredits < ActiveRecord::Migration
  def self.up
    create_table :requests_credits do |t|
    	t.decimal :amount,  :default => 0.0, :precision => 8, :scale => 2
    	t.string :state
    	t.integer :invoice_id, null: false
    	t.integer :transaction_id, null: false
      t.timestamps null: false
    end
    add_index :requests_credits, :invoice_id
    add_index :requests_credits, :transaction_id
  end

  def self.down
    drop_table :requests_credits
  end
end
