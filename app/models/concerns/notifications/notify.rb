module Notifications
	module Notify
		extend ActiveSupport::Concern
		
		included do 
			has_many :notifications, foreign_key: :sender_id
			has_many :notification_receipts
			has_many :notifications, through: :notification_receipts
		end

	end
end