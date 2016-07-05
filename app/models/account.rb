# ACCOUNT DOCUMENTATION
#
# The Accounts table represents... drum role please...  ACCOUNTS!!!
#
# The purpose is for a subscription based service.
#
# Example 1:
#    Someone signs up for a service with a monthly fee as opposed to one lump some.  The fee for the service
#    to be charged $25 per month.

#  NOTE: This has not been implemented and it is an option to delete this model if that is the desire
#

# == Schema Information
#
# Table name: accounts
#
#  id             :integer          not null, primary key
#  name           :string(255)      not null
#  account_type   :string(255)      not null
#  monthly_charge :decimal(8, 2)    default(0.0), not null
#  active         :boolean          default(TRUE), not null
#  created_at     :datetime
#  updated_at     :datetime
#


class Account < ActiveRecord::Base

  FREE  = 'Free'
  TRIAL = "Trial"
  EXPIRED_TRIAL = 'Expired Trial'
  UNSUBSCRIBED = 'Unsubscribed'
  SUBSCRIBED = "Subscribed"
  TYPES = {FREE => 0.00, TRIAL => 0.00, SUBSCRIBED => 100.00, EXPIRED_TRIAL => 0.00, UNSUBSCRIBED => 0.00}

  FREE_ID             = 1
  TRIAL_ID						= 2
  UNSUBSCRIBED        = 5 
  FREE_ACCOUNT_IDS    = [ FREE_ID, TRIAL_ID,  ]

  validates :name,            :presence => true,       :length => { :maximum => 255 }
  validates :account_type,    :presence => true,       :length => { :maximum => 255 }
  validates :monthly_charge,  :presence => true

  class << self
    
    def account_types
      TYPES.each do |k,v|
      #class_eval %{
      #  def self.#{k}
      #    find_by_name #{k}
      #  end
      #}
      end      
    end

    def trial
      find_by_name TRIAL
    end

    def expired_trial
      find_by_name EXPIRED_TRIAL
    end

    def subscribed
      find_by_name SUBSCRIBED
    end

    def free
      find_by_name FREE
    end

    def unsubscribed
      find_by_name UNSUBSCRIBED
    end

  end

  def trial?
    name.eql? self.class::TRIAL
  end

  def expired_trial?
    name.eql? self.class::EXPIRED_TRIAL    
  end

  def unsubscribed?
    name.eql? self.class::UNSUBSCRIBED
  end

end
