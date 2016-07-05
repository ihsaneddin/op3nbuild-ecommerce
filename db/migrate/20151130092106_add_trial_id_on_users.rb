class AddTrialIdOnUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :trial
  	add_column :users, :trial_id, :integer
  end
end
