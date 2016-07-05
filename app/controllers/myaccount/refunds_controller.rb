class Myaccount::RefundsController < Myaccount::BaseController
	include Trackings::Trackable

	load_and_authorize_resource class: 'Requests::Refund'
	skip_load_resource :only => [:create]

	before_action :find_refund, only: [:show, :cancel]

	self.trackable_resource_name= :refund
	track! 

	def index
		@refunds = current_user.refunds.includes(invoice: [:order]).paginate(page: 1, per_page: 1)
	end

	def new
		@refund = current_user.refunds.build order_no: params[:order_no]
	end

	def create
		@refund = current_user.refunds.build requests_refund_params
		if @refund.save
			redirect_to myaccount_refunds_path, notice: "Refund request has been created for order no. #{@refund.order_no}"
		else
			render :new
		end
	end

	def show;end

	def cancel
		if @refund.may_cancel?
			@refund.cancel!
			redirect_to myaccount_refunds_path, notice: "Refund request has been canceled."
		else
			raise CanCan::AccessDenied
		end
	end

	private

		def requests_refund_params
			params.require(:requests_refund).permit(:reason, :order_no, :note, :bank, :account_number)
		end

		def find_refund
			@refund ||= Requests::Refund.find params[:id]
		end

end