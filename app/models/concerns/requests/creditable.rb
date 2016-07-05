module Requests
	module Creditable

		extend ActiveSupport::Concern

		included do
			
			attr_accessor :credit_total
			has_many :requests_credits, class_name: 'Requests::Credit', foreign_key: :invoice_id

		end

		def unpaid_credit_request
			requests_credits.unpaid.first
		end

		def paid_credit_request
			requests_credits.paid.first
		end

		def rejected_credit_requests
			requests_credits.rejected
		end

		def may_generate_credit?
			paid? and order.paid? and order.shipments.present? and order.order_items.select("id", "shipment_id").where(shipment_id: nil).blank? and unpaid_credit_request.blank? and paid_credit_request.blank?
		end

		def total_contractor_credit
			(credit_items_total + credit_shipping_fee_total).round_at( 2 )
		end

		def credit_items_total
			self.credit_total = 0.0
	    order.order_items.each do |item|
	      self.credit_total = self.credit_total + item.credit_total
	    end
	    self.credit_total
		end

		def credit_shipping_fee_total
			order.shipping_charges
		end

	end
end