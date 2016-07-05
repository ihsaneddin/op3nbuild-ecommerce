class Admin::Balances::Requests::RefundsController < Admin::Balances::RequestsController

	self.transaction_types = [Requests::Transaction::REFUND]
	self.resource_class = 'Requests::refund'

	before_action :find_refund, only: [:update, :show, :approve, :reject, :cancel]
	self.trackable_resource_name= :credit
	track! 

	def new
		@refund = Requests::refund.new
	end

	def create
		@refund = Requests::refund.new requests_refund_params
		@refund.using_balance= @balance
		if @refund.save
			redirect_to admin_balances_requests_refunds_path, :notice => "Your refundal request has been created."
		else
			render :new
		end
	end

	def show;end

	def approve
		if @refund.may_approve?
			@refund.approve!
			redirect_to admin_balances_requests_refunds_path, notice: "refund has been approved."
		else
			raise CanCan::AccessDenied
		end
	end

	def cancel
		if @refund.may_cancel?
			if @refund.cancel!
				@refund.messages.create requests_message_params
				redirect_to admin_balances_requests_refunds_path, notice: "refund has been canceled."
			else
				render :show
			end
		else
			raise CanCan::AccessDenied
		end
	end

	def reject
		if @refund.may_reject?
			if @refund.reject!
				@refund.messages.create requests_message_params
				redirect_to admin_balances_requests_refunds_path, notice: "refund has been rejected."
			else
				render :show
			end
		else
			raise CanCan::AccessDenied
		end
	end

	private

		def find_refund
			@refund = @refund.context
		end

		def setup_credit
			@refund = Requests::Refund.new requests_refund_params
			@refund.using_balance= balance
		end

end
