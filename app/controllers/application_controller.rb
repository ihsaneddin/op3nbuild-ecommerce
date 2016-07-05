class ApplicationController < ActionController::Base
  require 'will_paginate/array'
  protect_from_forgery
  layout 'application'

  include Loggedable;
  include CartItems;
  include Notifications::UserNotifications;

  helper_method :current_user,
                :current_user_id,
                :most_likely_user,
                :random_user,
                :session_cart,
                :is_production_simulation,
                :search_product,
                :product_types,
                :myaccount_tab,
                :select_countries,
                :customer_confirmation_page_view,
                :sort_direction

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    flash[:alert] = 'Sorry you are not allowed to do that.'
    if current_user && current_user.admin?
      redirect_to admin_url
    else
      redirect_to root_url
    end
  end

  rescue_from ActiveRecord::DeleteRestrictionError do |exception|
    redirect_to :back, alert: exception.message
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  def product_types
    @product_types ||= ProductType.roots
  end

  protected

  def user_root_url user
    if user.admin? || user.super_admin?
      admin_url 
   else
      root_url
   end
  end

  private

  def customer_confirmation_page_view
    false
  end

  def pagination_page
    params[:page] ||= 1
    params[:page].to_i
  end

  def pagination_rows
    params[:rows] ||= 25
    params[:rows].to_i
  end

  def myaccount_tab
    false
  end

  def require_user
    redirect_to login_url and store_return_location and return if logged_out?
  end

  def store_return_location
    # disallow return to login, logout, signup pages
    disallowed_urls = [ login_url, logout_url ]
    disallowed_urls.map!{|url| url[/\/\w+$/]}
    unless disallowed_urls.include?(request.url)
      session[:return_to] = request.url
    end
  end

  def logged_out?
    !current_user
  end

  def search_product
    @search_product || Product.new
  end

  def is_production_simulation
    false
  end

  def redirect_back_or_default(default)
    default = root_url if current_user && (default == login_url)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def select_countries
    @select_countries ||= Country.form_selector
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def cc_params
    {
          :brand              => params[:type],
          :number             => params[:number],
          :verification_value => params[:verification_value],
          :month              => params[:month],
          :year               => params[:year],
          :first_name         => params[:first_name],
          :last_name          => params[:last_name]
    }
  end

  def expire_all_browser_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

end
