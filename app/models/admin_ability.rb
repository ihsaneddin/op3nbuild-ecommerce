# This is how cancan controls authorization.  For more details look at https://github.com/ryanb/cancan

class AdminAbility
  include CanCan::Ability

  # This method sets up the user's abilities to view admin pages
  #   look at https://github.com/ryanb/cancan for more info
  def initialize(user)
    
    user ||= User.new # guest user will not be allowed in the admin section
    alias_actions
    
    if user.super_admin?
      can :manage, :all
    elsif user.admin? || user.contractor?
      #can :manage, :all
      #can :read, :all
      #can :view_users, User do
      #  user.admin?
      #end
      #authorize! :view_users, @user
      #can :create_users, User do
      #  user.super_admin?
      #end
      #authorize! :create_users, @user
      #can :create_orders, User

      if user.trial || user.unsubscribed
        unless user.unsubscribed 
          can [:make], Product if user.products.count < 1
        end
        can [:read, :change], Product, contractor_id: user.id  
      else
        can :manage, Product, contractor_id: user.id
      end
      can :manage, Order, contractor_id: user.id
      can :manage, Shipment, order: {contractor_id: user.id}
      can :manage, ImageGroup, product: {contractor_id: user.id}
      can :manage, Property
      can :manage, Invoice

      if user.has_balance?
        can :manage, Requests::Balance, user_id: user.id
        can [:read, :make, :cancel], Requests::Transaction, balance_id: user.balance.id
        can :read, Requests::Credit
        can [:read, :make, :cancel], Requests::Withdraw
        can [:read], Requests::Refund, transaksi: {balance_id: user.balance.id} 
      end

      can :manage, :overview
    end
  end

  protected

    def alias_actions
      alias_action :index, :show, :to => :read
      alias_action :edit, :update, to: :change
      alias_action :new,:create, to: :make
      alias_action :destroy, to: :delete
      alias_action :index, :show, :new, :create, :edit, :update, :destroy, to: :crud
    end
end
