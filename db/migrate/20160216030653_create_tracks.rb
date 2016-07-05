class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
    	t.references :user, index: true
    	t.references :trackable, polymorphic: true
      t.timestamps null: false
    end
  end
end
