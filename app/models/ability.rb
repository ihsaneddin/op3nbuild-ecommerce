class Ability
  include CanCan::Ability

  # This method sets up the user's abilities to view  pages
  #   look at https://github.com/ryanb/cancan for more info
  def initialize(user)
    user ||= User.new # guest user
    alias_actions
    
    if user.super_admin? || user.admin?
      can :manage, :all
    else
      can :read, Order, :user_id => user.id
      can :manage, Order do |action, order|
        action != :destroy && order.state != 'complete' && order.user_id == user.id
      end
      can :read, Product
      can [:read, :cancel], Requests::Refund, user_id: user.id
      can :read, Requests::Refund, user_id: user.id
      can :make, Requests::Refund 
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