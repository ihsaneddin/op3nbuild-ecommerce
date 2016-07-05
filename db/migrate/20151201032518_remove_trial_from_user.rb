class RemoveTrialFromUser < ActiveRecord::Migration
  def change
  	remove_column :users, :trial_id
  end
end
