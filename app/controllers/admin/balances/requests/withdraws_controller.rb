class Admin::Balances::Requests::WithdrawsController < Admin::Balances::RequestsController

	self.transaction_types = [Requests::Transaction::WITHDRAW]
	self.resource_class = 'Requests::Withdraw'

	before_action :setup_withdraw, only: [:create]
	before_action :find_withdraw, only: [:update, :show, :approve, :reject, :cancel]
	self.trackable_resource_name= :withdraw
	track! 

	def new
		@withdraw = Requests::Withdraw.new
	end

	def create
		if @withdraw.save
			redirect_to admin_balances_requests_withdraws_path, :notice => "Your withdrawal request has been created."
		else
			render :new
		end
	end

	def show;end

	def approve
		if @withdraw.may_approve?
			@withdraw.approve!
			redirect_to admin_balances_requests_withdraws_path, notice: "Withdraw has been approved."
		else
			raise CanCan::AccessDenied
		end
	end

	def cancel
		if @withdraw.may_cancel?
			if @withdraw.cancel!
				@withdraw.messages.create requests_message_params
				redirect_to admin_balances_requests_withdraws_path, notice: "Withdraw has been canceled."
			else
				render :show
			end
		else
			raise CanCan::AccessDenied
		end
	end

	def reject
		if @withdraw.may_reject?
			if @withdraw.reject!
				@withdraw.messages.create requests_message_params
				redirect_to admin_balances_requests_withdraws_path, notice: "Withdraw has been rejected."
			else
				render :show
			end
		else
			raise CanCan::AccessDenied
		end
	end

	private

		def requests_withdraw_params
			params.require(:requests_withdraw).permit(:amount, :account_number, :bank)		
		end

		def find_withdraw
			@withdraw = @withdraw.context
		end

		def setup_withdraw
			@withdraw = Requests::Withdraw.new requests_withdraw_params
			@withdraw.using_balance= balance
		end
	
end
