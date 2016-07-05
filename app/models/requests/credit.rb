class Requests::Credit < ActiveRecord::Base
	include AASM
	include Requests::Transactable
	include Requests::Messageable
	include Tracking::Trackable
	include Comments::CommentableMethods
	include Notifications::Notifiable

	acts_as_commentable

	can_be_notified sender_notification: :who_send_notification, recipients_notification: :who_receive_notification, notifiable_attributes: [state: ['rejected', 'paid']]

	aasm column: :state do
    state :unpaid, initial: true
    state :rejected
    state :paid

    event :pay, after: :perform_transaction do
      transitions to: :paid, from: [:unpaid]
    end

    event :reject, after: :cancel_transaction do 
    	transitions to: :rejected, from: [:unpaid]
    end

  end

	belongs_to :transaksi, class_name: 'Requests::Transaction', foreign_key: :transaction_id
	belongs_to :invoice, class_name: 'Invoice'

	before_validation :setup_credit_amount

	validates :invoice, presence: true#, uniqueness: true
	validates :amount, numericality: { greater_than: 0, less_than: Proc.new {|c| c.invoice ? c.invoice.amount : 0 } }
	validate :validate_invoice, on: :create

	def is_eligible_to_be_processed?
		if persisted? and paid?
			invoice.paid? and invoice.invoice_type.eql?(invoice.class::PURCHASE)
		end
	end

	protected

		def validate_invoice
			if invoice.present?
				 self.errors.add(:invoice, "is invalid,") unless invoice.may_generate_credit? 
			end 
		end

		def setup_credit_amount
			self.amount= invoice.total_contractor_credit unless persisted?
		end

		def who_send_notification
			if self.last_changes_by.present?
          self.last_changes_by  
      end
		end

		def who_receive_notification
			recipients = []
			if self.last_changes_by.present?
        receiver = self.last_changes_by.super_admin?? self.transaksi.balance.user : User.first 
      	recipients  << receiver.notification_receipts.new(route: admin_balances_credit_path(self.transaksi)) 
      end
      recipients
		end

end
