module Requests
	module Transactable
		extend ActiveSupport::Concern

		included do 
			belongs_to :transaksi, class_name: 'Requests::Transaction', foreign_key: :transaction_id
			
			before_validation :setup_transaction

			validates :transaksi, presence: true

			attr_accessor :using_balance
		end

		def is_eligible_to_be_processed?
			raise NotImplementedError.new("You must implement #{__method}.")	
		end

		protected

			def setup_transaction
				unless transaksi
					begin
						Requests::Transaction.create_transaction(using_balance, self) do |transaksi|
							self.transaksi= transaksi
						end
					rescue ArgumentError => e
					end
				end
			end

			def perform_transaction
				if persisted?
					transaksi.class.perform_transaction transaksi.balance, self do |trans|
						block_given? ? yield(trans) : trans
					end
				end
			end

			def cancel_transaction
				transaksi.cancel!
			end

	end
end