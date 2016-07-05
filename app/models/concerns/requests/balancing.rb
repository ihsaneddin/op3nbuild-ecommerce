module Requests
	module Balancing
		
		extend ActiveSupport::Concern

		included do
			has_one :balance, class_name: 'Requests::Balance', foreign_key: :user_id
			has_many :refunds, class_name: 'Requests::Refund'#, foreign_key: :issued_by			
			
			after_create :init_balance!

		end

		def init_balance!
			return balance if balance
			build_balance 
			save
			balance
		end

		def has_balance?
			balance.present?
		end

	end
end