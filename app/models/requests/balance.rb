class Requests::Balance < ActiveRecord::Base

	belongs_to :user
	has_many :transactions

	def transact transaction_obj
		meth = transaction_obj.tipe
		begin 
			send(meth, transaction_obj.context) 
		rescue NoMethodError => e
			raise NoMethodError.new "Invalid transaction object."
		end
		block_given? ? yield : true 
	end

	def can_be_withdrew?
		actual_proposed_amount > 0
	end

	def actual_proposed_amount
		amount - sum_of_pending_withdraws
	end

	def sum_of_pending_withdraws
		transactions.joins(:withdraw).select('id', "withdraws.transaction_id", "withdraws.amount", "withdraws.state").where(requests_withdraws: {state: 'pending'}).sum(:amount)
	end

	protected

		def valid_to_perform_transaction transaksi
			if transaksi.balance.eql?(self) and transaksi.is_eligible?
				if block_given?
				  yield
				else
					return true
				end
			else
				raise ArgumentError.new 'Transaction is not eligible to be processed.'
			end
		end

		def credit transaksi
			valid_to_perform_transaction(transaksi) do 
				self.amount += transaksi.context.amount
				self.save
			end
		end

		def withdraw transaksi
			valid_to_perform_transaction transaksi do 
				self.amount -= transaksi.context.amount
				self.save
			end
		end

		def refund transaksi
			valid_to_perform_transaction transaksi do 
				self.amount -= transaksi.context.invoice.total_contractor_credit
				self.save
			end
		end

end
