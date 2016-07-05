class WelcomeController < ApplicationController

  layout 'welcome'

  def index
    @featured_product = Product.featured
    @best_selling_products = Product.limit(5)
    @other_products  ## search 2 or 3 categories (maybe based on the user)
    @products = Product.active.includes(:variants).paginate(:page => params[:featured], :per_page => 15)
    unless current_user.nil?
      @orders = current_user.finished_orders.find_myaccount_details.paginate(:page => params[:select], :per_page => 5)
      # @products2 = Product.active.includes(:variants).where(contractor_id: current_user.id).paginate(:page => params[:select], :per_page => 5)
    end
    unless @featured_product
      if current_user && current_user.admin?
        #redirect_to admin_merchandise_products_url
      else
        #redirect_to login_url
      end
    end
  end
end
