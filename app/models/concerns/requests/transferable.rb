module Requests
	module Transferable
		extend ActiveSupport::Concern

		included do 

			belongs_to :bank_account
			delegate :bank, to: :bank_account, prefix: true
			delegate :account_number, to: :bank_account, prefix: true

			before_validation :setup_bank_account

			validates :bank, presence: true, on: :create, unless: :bank_account
			validates :bank_account, presence: true
			validates :account_number, presence: true, numericality: {allow_blank: true}, on: :create, unless: :bank_account
			
			attr_accessor :account_number, :bank

		end

		protected

			def setup_bank_account
				if bank_account.blank? and using_balance.present?
					bank_params = {account_number: account_number, bank: bank}
					begin 
						Requests::BankAccount.create_bank using_balance.user, bank_params do |proposed_bank_account| 
							self.bank_account= proposed_bank_account
						end
					rescue ArgumentError => e
					end
				end
			end

	end
end