class Requests::Transaction < ActiveRecord::Base
	include AASM

	aasm column: :state do
    state :pending, initial: true
    state :canceled
    state :processed

    event :process do
      transitions to: :processed, from: [:pending]
    end
    event :cancel do 
    	transitions to: :canceled, from: [:pending]
    end
  end

	belongs_to :balance
	has_one :credit
	has_one :withdraw
	has_one :refund

	CREDIT = 'credit'
	WITHDRAW = 'withdraw'
	REFUND = 'refund'
	TYPES = [CREDIT,WITHDRAW,REFUND]

	validates :balance, presence: true
	validates :tipe, presence: true, inclusion: {in: TYPES}

	attr_accessor :push_to_store_balance

	def context
		self.send(tipe.to_sym)
	end

	def store_balance
		@store_balance ||= Requests::StoreBalance.balance
	end

	def is_eligible?
		persisted? and pending? and context.is_eligible_to_be_processed?
	end

	class << self

		def create_transaction balance, transaction_context_obj 
			ensure_balance(balance, transaction_context_obj) do |bal|
				context = transaction_context_obj.class.name.demodulize.downcase
				transaksi = transaction_context_obj.transaksi
				if transaksi.blank? || !transaksi.persisted?
					transaksi = new balance: bal, tipe: context
					unless transaksi.save 
						raise ArgumentError.new "Balance or transaction context object is invalid."
					end
				end
				block_given? ? yield(transaksi) : transaksi
			end
		end
		
		def perform_transaction balance, transaction_context_obj, opts={ push_to_balance: true, push_to_store_balance: true }
			ensure_balance(balance, transaction_context_obj) do |bal|
				context = transaction_context_obj.class.name.demodulize.downcase
				transaksi = transaction_context_obj.transaksi
				if transaksi.blank? || !transaksi.persisted?
					transaksi = create_transaction bal, transaction_context_obj
				end
				transaksi.balance= bal if transaksi.balance.blank?
				if block_given?
					yield transaksi
				end
				transaksi.balance.send transaksi.tipe.to_sym, transaksi if opts[:push_to_balance]
				transaksi.store_balance.send transaksi.tipe.to_sym, transaksi if opts[:push_to_store_balance]
				transaksi.process!
			end
		end

		def ensure_balance balance, trans_context
			unless balance.is_a? Requests::Balance
				if trans_context.respond_to?(:invoice) and trans_context.send(:invoice).present?
					balance= trans_context.invoice.order.contractor.init_balance!
				elsif trans_context.respond_to?(:bank_account) and trans_context.send(:bank_account).present?
					balance= bank_account.user.init_balance!
				end
			end
			if balance.is_a? Requests::Balance
				block_given?? yield(balance) : balance
			else
				raise ArgumentError.new "Balance is invalid."
			end	
		end
		
	end

end