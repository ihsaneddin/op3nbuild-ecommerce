class AddRequestsAccountIdOnRequestsWithdraw < ActiveRecord::Migration
  def change
  	add_column :requests_withdraws, :bank_account_id, :integer, null: false, index: true
  end
end
