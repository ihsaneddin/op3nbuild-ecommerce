class Requests::Refund < ActiveRecord::Base
	include AASM
	before_validation :setup_invoice
	include Requests::Transactable
	include Requests::Transferable
	include Requests::Messageable
	include Comments::CommentableMethods
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
    event :reject, after: :cancel_transaction do 
    	transitions to: :rejected, from: [:pending]
    end
    event :approve, after: :perform_transaction do 
    	transitions to: :succeed, from: [:pending]
    end
  end

	belongs_to :invoice, class_name: 'Invoice'
	belongs_to :user

	validates :reason, presence: true, inclusion: {in: ReturnReason::REASONS}
	validates :invoice, presence: true#, uniqueness: true
	validates :user, presence: true
	validates :invoice, presence: true
	
	validate :valid_order, on: :create

	attr_accessor :order_no, :using_balance, :bank, :account_number

	def is_eligible_to_be_processed?
		persisted? and succeed?
	end

	protected

		def valid_order
			self.errors.add(:order_no, "is invalid") if self.invoice.blank? or !self.invoice.is_eligible_to_be_refunded?
		end

		def setup_invoice
			if order_no.present? and invoice.blank?
				order = Order.find_by number: order_no
				if order and order.paid? and order.paid_invoices.present?
					self.invoice= order.paid_invoices.first
					self.using_balance= order.contractor.balance 	
					self.amount= self.invoice.amount
				end
			end
		end


end
