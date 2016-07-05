class AddRouteOnNotificationReceipts < ActiveRecord::Migration
  def change
  	add_column :notification_receipts, :route, :string
  end
end
