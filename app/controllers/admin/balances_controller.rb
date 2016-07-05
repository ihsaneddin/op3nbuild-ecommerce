class Admin::BalancesController < Admin::BaseController
	
	include Trackings::Trackable

	class_attribute :transaction_types
	class_attribute :resource_class
	self.transaction_types = Requests::Transaction::TYPES
	self.resource_class = 'Requests::Transaction'

	before_filter :balance_owner
	before_filter :balance

	helper_method :sort_column, :sort_direction, :balance, :balance_owner, :pagination_page, :pagination_rows, :last_page?, :comments_for


	load_and_authorize_resource class: self.resource_class

	def index
		@transactions = balance.transactions.accessible_by(current_ability).includes(:credit, :withdraw, :refund).where(tipe: types).order(sort_column + " " + sort_direction).
                                            paginate(:page => pagination_page, :per_page => pagination_rows)
	end

	protected

		def sort_column
	    begin
	    	self.class.resource_class.constantize.column_names.include?(params[:sort]) ? params[:sort] : "id"
	  	rescue
	  		"id"
	  	end
	  end

	  def pagination_rows
	    params[:rows] ||= 25
	    params[:rows].to_i
	  end

	  def sort_direction
	    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
	  end

		def balance_owner
			@balance_owner ||= current_user
		end

		def balance
			@balance ||= balance_owner.super_admin?? Requests::StoreBalance.balance : balance_owner.balance
			if @balance.nil?
				balance_owner.init_balance!
				@balance = balance_owner.balance
			end
			@balance
		end

		def types
			self.class.transaction_types
		end

		def requests_message_params
			params.require(:requests_message).permit(:content)
		end

		def last_page? collection
			collection.total_pages == collection.current_page
		end

		def comments_for context
			Requests::Comment.find_comments_for_commentable context.class.name, context.id
		end

end
