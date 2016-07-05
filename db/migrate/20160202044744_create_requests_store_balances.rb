class CreateRequestsStoreBalances < ActiveRecord::Migration
  def change
    create_table :requests_store_balances do |t|
    	t.decimal :hold_credit_amount, :default => 0.0, :precision => 8, :scale => 2
    	t.decimal :actual_credit_amount, :default => 0.0, :precision => 8, :scale => 2
    	t.decimal :credit_amount, :default => 0.0, :precision => 8, :scale => 2
      t.timestamps null: false
    end
  end
end
