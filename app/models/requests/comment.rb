module Requests
	class Comment < ::Comment
	
		include Comments::CommentMethods
		include Notifications::Notifiable

		belongs_to :commentable, :polymorphic => true

		can_be_notified sender_notification: :user, recipients_notification: :who_receive_notification, notification_yaml_text: :notification_subject, notification_on: :after_create

		protected

			def who_receive_notification
				receivers = []
				if %w{ credit withdraw refund }.include? commentable.class.name.demodulize.downcase
					receivers << (self.user.eql?(commentable.transaksi.balance.user) ? User.first : commentable.transaksi.balance.user)
					receivers + self.commentable.comments.includes(:user).select(:id, :user_id).map { |c| user unless user.eql?(self.user) }.compact
					receivers.compact.map{|rec| rec.notification_receipts.new( route: commentable_path(rec)) }
				end
			end

			def commentable_path recipient
				commentable_class= commentable.class.name.demodulize.downcase
				case commentable_class
				when 'refund'
					if recipient.eql? commentable.try(:user)
						myaccount_refund_path(commentable.id)
					else
						send "admin_balances_requests_#{commentable_class}_path", commentable.transaksi
					end
				when 'credit'
					admin_balances_credit_path(commentable.transaksi)
				when 'withdraw'
					admin_balances_requests_withdraw(commentable.transaksi)
				end
			end

			def notification_subject
				if user.present? and commentable.present?
					I18n.t("notifications.comment.commentable.#{commentable_type.demodulize.downcase}", sender: user.try(:display_name), state: commentable.try(:state))
				end
			end

	end
end