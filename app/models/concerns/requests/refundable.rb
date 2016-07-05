module Requests
	module Refundable
		extend ActiveSupport::Concern

		included do

			has_many :refunds, class_name: 'Requests::Refund', foreign_key: :invoice_id

		end

		def is_eligible_to_be_refunded?
			self.paid? and pending_refund.blank? and succeed_refund.blank?
		end

		def pending_refund
			refunds.pending.first
		end

		def rejected_refunds
			refunds.rejected
		end

		def canceled_refunds
			refunds.canceled
		end

		def succeed_refund
			refunds.succeed.first
		end

	end
end