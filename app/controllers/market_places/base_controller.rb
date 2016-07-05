class MarketPlaces::BaseController < ApplicationController

  layout 'market_places'
  self.use_marketplace = true

  before_action :contractor_present!

  helper_method :current_contractor, :contractor_context

  #rescue_from ActiveRecord::RecordNotFound do |exception|
    #redirect_to 404 page   
  #end
  
  def product_types
    @product_types ||= ProductType.roots
  end

  def current_ability
    @current_ability ||= MarketPlacesAbility.new(current_contractor, current_user)
  end

  private

  def contractor_param
    params[:contractor]
  end

  def contractor_present!
    raise ActiveRecord::RecordNotFound unless current_contractor
  end

  def current_contractor
    return @current_contractor if defined?(@current_contractor)
    contractor!
  end

  def contractor!
    unless @current_contractor
      session[:contractor] = [] if session[:contractor].nil?
      #if session[:contractor].empty? || !session[:contractor].include?(contractor_param)
        @current_contractor = Contractor.find_contractor_by_slug contractor_param
        session[:contractor] << @current_contractor.slug unless session[:contractor].include?(@current_contractor.slug)
      #end
    end
    @current_contractor
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

  def session_cart
    return @session_cart if defined?(@session_cart)
    session_cart!
  end
  # use this method if you want to force a SQL query to get the cart.
  def session_cart!
    carts = cookies[:carts]
    if carts.present?
      carts = JSON.parse(carts) rescue carts
      if carts.is_a? Hash
        if carts["#{current_contractor.slug}"]
          @session_cart = Cart.includes(:shopping_cart_items).find_by_id(carts["#{current_contractor.slug}"])
        end
        unless @session_cart
          @session_cart = Cart.create(:user_id => current_user_id, contractor: current_contractor)
          carts["#{@session_cart.contractor.slug}"] = @session_cart.id
          cookies[:carts] = carts.to_json
        end
      end
    elsif current_user && current_user.current_cart_on_contractor(current_contractor)
      @session_cart = current_user.current_cart_on_contractor current_contractor
      carts = {} if carts.nil?
      carts["#{@session_cart.contractor.slug}"] =@session_cart.id
      cookies[:carts] = carts.to_json
    else
      @session_cart = Cart.create contractor: current_contractor
      cookies[:carts] = { "#{current_contractor.slug}" => @session_cart.id }.to_json
    end
    @session_cart
  end

  ## The most likely user can be determined off the session / cookies or for now lets grab a random user
  #   Change this method for showing products that the end user will more than likely like.
  #
  def most_likely_user
    current_user ? current_user : random_user
  end

  ## TODO cookie[:hadean_user_id] value needs to be encrypted ### Authlogic persistence_token might work here
  def random_user
    return @random_user if defined?(@random_user)
    @random_user = cookies[:hadean_uid] ? User.find_by_persistence_token(cookies[:hadean_uid]) : nil
  end

  def merge_carts
    if !!current_user
      session_cart.merge_with_previous_cart!
    end
  end

  def set_user_to_cart_items(user)
    if session_cart.user_id != user.id
      session_cart.update_attribute(:user_id, user.id )
    end
    session_cart.cart_items.each do |item|
      item.update_attribute(:user_id, user.id ) if item.user_id != user.id
    end
  end

  def contractor_context
    {contractor: current_contractor.slug}
  end

end
