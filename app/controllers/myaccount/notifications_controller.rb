class Myaccount::NotificationsController < Myaccount::BaseController

	def index
		#@notifications = Notification.includes(:receipts).find_notifications_for(current_user).paginate(:page => pagination_page, :per_page => pagination_rows)
		#@notifications = Notification.includes(:receipts).select("DISTINCT ON (notifiable_id) *").paginate(:page => pagination_page, :per_page => pagination_rows)
		datas = NotificationReceipt.joins(:notification).where(user_id: current_user).select("DISTINCT ON (notifiable_id) *")
		@notifications = Notification.find(datas.map(&:notification_id)).paginate(page: pagination_page, per_page: pagination_rows)
		#@notifications = Notification.includes(:receipts).joins(:notification).where(user_id: current_user).select("DISTINCT ON (notifiable_id) *").paginate(:page => pagination_page, :per_page => pagination_rows)
	end

	def show
		
	end

	def update
		if notification_receipt.update notification_receipt_params && NotificationReceipt.where(user_id: current_user, read: false).update_all(read: true)
			respond_to do |f|
				f.json { render json: @notification_receipt.to_json }
			end
		else
			render nothing: true
		end
	end

	private

		def notification_receipt
			@notification_receipt ||= Notification.find(params[:id]).notification_receipt_for(current_user)
		end

		def notification_receipt_params
			params.require(:notification_receipt).permit(:read)
		end

end