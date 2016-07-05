class AddTrialToUser < ActiveRecord::Migration
  def change
  	add_column :users, :trial, :boolean, default: true
  end
end
