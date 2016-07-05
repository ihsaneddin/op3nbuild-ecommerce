class Requests::StoreBalance < ActiveRecord::Base

	validates :actual_credit_amount, presence: true, numericality: true
	validates :hold_credit_amount, presence: true, numericality: true
	validates :credit_amount, presence: true, numericality: true
	validate :reject_new_store_balance
	validate :actual_credit_plus_hold_credit_must_be_equal_credit

	class << self

		def balance
			if self.first.nil?
				new_store_balance = new
				new_store_balance.save
				new_store_balance.init_balance
			end
			self.first
		end

	end

	def init_balance
		calculate_existing_balance
	end

	def amount 
		credit_amount
	end

	def transactions
		Requests::Transaction.includes(:withdraw, :refund, credit: :invoice).all
	end

	def transact transaction_obj
		meth = transaction_obj.tipe
		begin 
			send(meth, transaction_obj.context) 
		rescue NoMethodError => e
			raise NoMethodError.new "Invalid transaction object."
		end
		block_given? ? yield : true 
	end

	protected

		def valid_to_perform_transaction transaksi, options= {raise_error: true}
			if transaksi.is_eligible?
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
				lance_fee_amount = transaksi.context.invoice.amount - transaksi.context.amount
				self.hold_credit_amount += transaksi.context.amount
				self.actual_credit_amount += lance_fee_amount
				self.credit_amount += transaksi.context.invoice.amount
				self.save
			end
		end

		def withdraw transaksi
			valid_to_perform_transaction(transaksi) do 
				withdraw_amount = transaksi.context.amount
				self.hold_credit_amount -= withdraw_amount
				self.credit_amount = self.hold_credit_amount + self.actual_credit_amount
				self.save
			end
		end

		def refund transaksi
			valid_to_perform_transaction(transaksi) do 
				refund_amount = transaksi.context.amount
				refund_holding_credit = transaksi.context.invoice.total_contractor_credit
				refund_actual_credit = transaksi.context.invoice.amount - refund_holding_credit
				self.hold_credit_amount -= refund_holding_credit
				self.actual_credit_amount -= refund_actual_credit
				self.credit_amount = self.hold_credit_amount + self.actual_credit_amount
				self.save
			end
		end

		def reject_new_store_balance
			unless persisted?
				errors.add(:base, "New store balance is not permitted.") if self.class.first.present?
			end
		end

		def actual_credit_plus_hold_credit_must_be_equal_credit
			unless (self.hold_credit_amount + self.actual_credit_amount).eql? self.credit_amount
				error.add(:base, "Invalid credit amount total.")
			end
		end

		def calculate_existing_balance
			transactions.each do |t|
				perform_transaksi t, raise_error: false
			end
		end

end
