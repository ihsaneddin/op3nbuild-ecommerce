class Admin::Balances::CreditsController < Admin::BalancesController

	self.transaction_types = [Requests::Transaction::CREDIT]
	self.resource_class = 'Requests::Credit'

	before_action :setup_credit, only: [:create]
	before_action :find_credit, only: [:update, :show, :pay, :reject]
	self.trackable_resource_name= :credit
	track! 

	def new
		@credit = Requests::Credit.new
	end

	def create
		if @credit.save
			redirect_to admin_balances_credits_path, :notice => "Your credit request has been created."
		else
			redirect_to admin_balances_credits_path, :notice => "Your proposed invoice is invalid."
		end
	end

	def show;end

	def pay
		if @credit.may_pay?
			@credit.pay!
			redirect_to admin_balances_credits_path, notice: "credit has been paid."
		else
			raise CanCan::AccessDenied
		end
	end

	def reject
		if @credit.may_reject?
			if @credit.reject!
				@credit.messages.create requests_message_params
				redirect_to admin_balances_credits_path, notice: "credit has been rejected."
			else
				render :show
			end
		else
			raise CanCan::AccessDenied
		end
	end

	private

		def requests_credit_params
			params.require(:requests_credit).permit(:invoice_id)		
		end

		def find_credit
			@credit = @credit.context
		end

		def setup_credit
			@credit = Requests::Credit.new requests_credit_params
			@credit.using_balance= balance
		end

end
