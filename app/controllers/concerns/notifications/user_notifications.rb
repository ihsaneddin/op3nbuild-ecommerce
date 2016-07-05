module Notifications
	module UserNotifications
		extend ActiveSupport::Concern

		included do 
			before_action :user_unread_notifications
			helper_method :unread_notifications
		end

		protected

			def user_unread_notifications
				activate_authlogic unless UserSession.activated?
				if current_user
					@unread_notifications = Notification.find_unread_notifications_for current_user
					#datas = NotificationReceipt.joins(:notification).where(user_id: current_user, read: 'f').select("DISTINCT ON (notifiable_id) *")
					#@unread_notifications = Notification.find(datas.map(&:notification_id))
				end
			end

			def unread_notifications
				@unread_notifications
			end

	end
end