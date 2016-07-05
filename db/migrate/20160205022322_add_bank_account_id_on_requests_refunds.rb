class AddBankAccountIdOnRequestsRefunds < ActiveRecord::Migration
  def change
  	add_column :requests_refunds, :bank_account_id, :integer, null: false, index: true
  end
end
