class Requests::Withdraw < ActiveRecord::Base
	include AASM
	include Requests::Transactable
	include Requests::Transferable
    include Requests::Messageable
    include Comments::CommentableMethods
    include Tracking::Trackable
    include Notifications::Notifiable

    acts_as_commentable

    can_be_notified sender_notification: :who_send_notification, recipients_notification: :who_receive_notification, notifiable_attributes: [state: ['canceled', 'rejected', 'succeed']]

	aasm column: :state do
        state :pending, initial: true
        state :canceled
        state :rejected
        state :succeed

        event :cancel, after: :cancel_transaction do
          transitions to: :canceled, from: [:pending]
        end
        event :approve, after: :perform_transaction do 
        	transitions to: :succeed, from: [:pending]
        end
        event :reject, after: :cancel_transaction do 
        	transitions to: :rejected, from: [:pending]
        end
    end

	validates :amount, presence: true, numericality: {greater_than: 0, less_than: ::Proc.new {|w| (w.transaksi && w.transaksi.balance) ? w.transaksi.balance.actual_proposed_amount : 0 }}

	attr_accessor :account_number, :bank

	def is_eligible_to_be_processed?
		persisted? and succeed?
	end

    protected

      def who_send_notification
        
        if self.last_changes_by.present?
          self.last_changes_by  
        end
      end

      def who_receive_notification
        recipients = []
        if self.last_changes_by.present?
        receiver = self.last_changes_by.super_admin?? self.transaksi.balance.user : User.first 
        recipients  << receiver.notification_receipts.new(route: admin_balances_requests_withdraw_path(self.transaksi)) 
        end
        recipients
      end

end
