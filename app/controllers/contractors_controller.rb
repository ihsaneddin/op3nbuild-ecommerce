class ContractorsController < ApplicationController

	def index
		@contractors = Contractor.active.paginate(per_page: 20, page: params[:page])
	end

	def show
		
	end

	protected

end