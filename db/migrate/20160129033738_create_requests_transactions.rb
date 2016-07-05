class CreateRequestsTransactions < ActiveRecord::Migration
  def change
    create_table :requests_transactions do |t|
    	t.string :state
    	t.string :tipe
    	t.integer :balance_id, null: false
      t.timestamps null: false
    end
    add_index :requests_transactions, :balance_id 
  end
end
