module Notifications
	module NotificationMethods
		extend ActiveSupport::Concern

			included do 
				extend Finders
				scope :in_order, -> { model.order('created_at ASC') }
				scope :recent, -> { model.order("created_at DESC") }
				scope :unread, -> { model.recent.where(read: false) }

				belongs_to :notifiable, polymorphic: true
				belongs_to :sender, class_name: 'User', foreign_key: :sender_id
				has_many :receipts, class_name: 'NotificationReceipt', foreign_key: :notification_id
				has_many :users, through: :receipts

			end

			module Finders

				def find_notifications_for recipient
					joins(:receipts).where(["notification_receipts.user_id = ?", recipient.id]).order("notifications.created_at DESC")
				end

				def find_unread_notifications_for recipient
					find_notifications_for(recipient).where(["notification_receipts.read = ?", false])
				end

				def find_notifications_send_by sender
					where(["sender_id = ?", sender.id]).order("created_at DESC")
				end

				def find_notifications_for_notifiable notifiable_type, notifiable_id
					recent.where(["notifiable_type = ? and notifiable_id = ?", notifiable_type, notifiable_id])
				end

			end

			def notification_receipt_for(user)
				receipts.order("created_at").find_by_user_id(user.id)
			end

	end
end