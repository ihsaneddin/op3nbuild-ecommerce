# This is how cancan controls authorization.  For more details look at https://github.com/ryanb/cancan
class MarketPlacesAbility
  include CanCan::Ability

  def initialize current_contractor, current_user

    can :read, Product, contractor_id: current_contractor.id

    if current_user
      user = current_user
      can :read, Order, :user_id => user.id
      can :manage, Order do |action, order|
        action != :destroy && order.state != 'complete' && order.user_id == user.id
      end
    end

  end

end