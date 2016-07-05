class CreateRequestsMessages < ActiveRecord::Migration
  def change
    create_table :requests_messages do |t|
    	t.references :messageable, polymorphic: true
    	t.string :title
    	t.text :content
      t.timestamps null: false
    end
  end
end
