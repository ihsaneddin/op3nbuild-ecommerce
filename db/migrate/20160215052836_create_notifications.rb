class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
    	t.references :notifiable, polymorphic: true
    	t.integer :recipient_id, index: true
    	t.integer :sender_id, index: true
    	t.string :subject
    	t.text :body
    	t.boolean :read
    	t.boolean :send_email
      t.timestamps null: false
    end
  end
end
