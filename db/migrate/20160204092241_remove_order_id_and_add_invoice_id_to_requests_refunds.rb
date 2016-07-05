class RemoveOrderIdAndAddInvoiceIdToRequestsRefunds < ActiveRecord::Migration
def up
    remove_index :requests_refunds, :order_id if index_exists?(:requests_refunds, :order_id)
    remove_column :requests_refunds, :order_id
    add_column :requests_refunds, :invoice_id, :integer
  	add_index :requests_refunds, :invoice_id
  	add_column :requests_refunds, :user_id, :integer
  	add_index :requests_refunds, :user_id
  end

  def down
  	add_column :requests_refunds, :order_id, :integer
  	add_index :requests_refunds, :order_id
  	remove_index :requests_refunds, :invoice_id if index_exists?(:requests_refunds, :invoice_id)
    remove_column :requests_refunds, :invoice_id
    remove_index :requests_refunds, :user_id if index_exists?(:requests_refunds, :user_id)
    remove_column :requests_refunds, :user_id
  end
end
