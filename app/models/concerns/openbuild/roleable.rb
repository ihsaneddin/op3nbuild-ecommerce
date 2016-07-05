#included on User
module Openbuild
  module Roleable
    extend ActiveSupport::Concern

    module ClassMethods
      #return user if user has role contractor
      #otherwise raise ActiveRecord::RecordNotFound Exception
      #@input [String,Integer]
      #@return [User, Exception]
      def find_contractor_by_slug slug
        user = friendly.find slug
        raise ActiveRecord::RecordNotFound unless user.contractor?
        user
      end

    end

    # returns true if the user has role contractor otherwise it return false
    #
    # @param [none]
    # @return [ Boolean ]
    def contractor?
      role?(:contractor)
    end

    #returns true if the user is upgraded to contractor user otherwise it return false
    #
    #@param [none]
    #@return [ Boolean ]
    def upgrade
      begin 
        self.roles << Role.find_by_name(Role::CONTRACTOR) rescue nil
        self.roles << Role.find_by_name(Role::ADMIN) #temporary
        activate_products
        return true
      rescue => e
        return false
      end
    end

    #returns true if the user is downgraded to customer user otherwise it return false
    #
    #@param [none]
    #@return [ Boolean ]
    def downgrade
      begin
        self.roles = []
        deactivate_products
        return true
      rescue => e
        return false
      end
    end

    protected
      
      #returns void, activate all user's products when upgrading
      #
      #@param [none]
      #@return [ Nil ]
      def activate_products
        products.each do |product|
          product.deleted_at = nil
          product.save
        end
      end

      #returns void, activate all user's products when upgrading
      #
      #@param [none]
      #@return [ Nil ]
      def deactivate_products
        products.update_all(:deleted_at => Time.zone.now) unless products.empty?
      end
  end
end