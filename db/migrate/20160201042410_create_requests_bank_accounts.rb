class CreateRequestsBankAccounts < ActiveRecord::Migration
  def change
    create_table :requests_bank_accounts do |t|
    	t.integer :user_id, null: false
    	t.string :account_number, null: false
    	t.string :bank, null: false
    	t.string :tipe
      t.timestamps null: false
    end
    add_index :requests_bank_accounts, :user_id
  end
end
