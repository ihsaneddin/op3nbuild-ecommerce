class CreateNotificationReceipts < ActiveRecord::Migration
  def change
    create_table :notification_receipts do |t|
    	t.references :user, index: true
    	t.references :notification, index: true
    	t.boolean :read, default: false
      t.timestamps null: false
    end
  end
end
