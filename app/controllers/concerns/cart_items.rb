module CartItems 
	extend ActiveSupport::Concern

	included do 
		self.class_attribute :use_marketplace
		self.use_marketplace = false
	end

	def session_cart
    return @session_cart if defined?(@session_cart)
    session_cart!
  end
  # use this method if you want to force a SQL query to get the cart.
  
  def session_cart!
  	if self.class.use_marketplace
  		marketplace_session_cart!
  	else
  		global_session_cart!
  	end
  end

  def global_session_cart!
    carts = cookies[:carts]
    if carts.present?
     	carts = JSON.parse(carts) rescue {} 
    	carts = Cart.includes(:shopping_cart_items, :contractor).where(id: carts.values)
    	@session_cart = carts  	
    elsif current_user && current_user.current_carts
      carts = {} if carts.nil?
      @session_cart = current_user.current_carts
      @session_cart.each{|c| carts[c.contractor.slug.to_sym] = c.id} 
    	cookies[:carts] = carts.to_json
    else
     	@session_cart = {}
    end
    @session_cart
  end

  def marketplace_session_cart!
    carts = cookies[:carts]
    if carts.present?
      carts = JSON.parse(carts) rescue carts
      if carts.is_a? Hash
        if carts["#{current_contractor.id}"]
          @session_cart = Cart.includes(:shopping_cart_items).find_by_id(carts["#{current_contractor.id}"])
        end
        unless @session_cart
          @session_cart = Cart.create(:user_id => current_user_id, contractor: current_contractor)
          carts["#{@session_cart.contractor.id}"] = @session_cart.id
          cookies[:carts] = carts.to_json
        end
      end
    elsif current_user && current_user.current_cart_on_contractor(current_contractor)
      carts = {} if carts.nil?
      @session_cart = current_user.current_cart_on_contractor current_contractor
      carts["#{@session_cart.contractor.id}"] =@session_cart.id
      cookies[:carts] = carts.to_json
    else
      @session_cart = Cart.create contractor: current_contractor
      cookies[:carts] = { "#{current_contractor.id}" => @session_cart.id }.to_json
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
      session_cart.merge_with_previous_cart! if session_cart.is_a? Cart
    end
  end

  def set_user_to_cart_items(user)
    if  session_cart.is_a? Cart
      if session_cart.user_id != user.id
        session_cart.update_attribute(:user_id, user.id )
      end
      session_cart.cart_items.each do |item|
        item.update_attribute(:user_id, user.id ) if item.user_id != user.id
      end
    end
  end

end