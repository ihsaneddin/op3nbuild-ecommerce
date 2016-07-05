class Requests::BankAccount < ActiveRecord::Base

	has_many :withdraws
	belongs_to :user

	validates :account_number, presence: true, numericality: true
	validates :bank, presence: true
	validates :user_id, presence: true

	class << self

		def create_bank account_owner, bank_params = { account_number: nil, bank: nil }
			bank = new bank_params
			bank.user= account_owner
			unless bank.save
				raise ArgumentError.new "Bank params is not valid."
			end
			block_given?? yield(bank) : bank
		end

	end

end
