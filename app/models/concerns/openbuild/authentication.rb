
module Openbuild
  module Authentication

    extend ActiveSupport::Concern

    included do
      #before_create :set_trial_account
      after_initialize :set_trial
      before_create :set_account
      attr_accessor :trial, :expired_trial, :unsubscribed
    end

    module ClassMethods
      def get_existing_openbuild_user options = {}
        begin
          authentication_token = options.delete(:authentication_token)
          request = Connection::Request.new :get, "#{ENV['openbuild_existed_user_url']}/#{authentication_token}", { params: {user: options } }, Rails.env.production?
          request.invoke
          return request.success?? Openbuild::User.new(request.response['user']) : nil
        rescue => e
          return nil
        end
      end
    end

    def remove_trial
      self.account = Account.subscribed
      self.save
    end

    def cancel_trial
      self.account = Account.expired_trial
      self.save 
    end

    def activate_account
      remove_trial
    end

    def deactivate_account
      self.account = Account.unsubscribed
      self.save
    end

    def rollback_trial openbuild_user
      if openbuild_user.trial
        if openbuild_user.trial_expired
          self.account = Account.expired_trial
        else
          self.account = Account.trial
        end
        self.save
      end
    end
    
    protected
      #def set_trial_account
      #  self.Account = Account.trial unless account_id
      #end

      def set_trial
        if account
          self.trial = account.trial?
          self.expired_trial = account.expired_trial?
          self.unsubscribed = self.account.unsubscribed?
        end
      end

      def set_account
        unless persisted?
          if self.trial
            if self.expired_trial
              self.account = Account.expired_trial
            else
              self.account = Account.trial 
            end
          else
            self.account = Account.free
          end
        end
      end

  end
end