class MarketPlaces::Shopping::CartItemsController < MarketPlaces::Shopping::BaseController

  # GET /shopping/cart_items
  def index
    @cart_items       = session_cart.shopping_cart_items
    @saved_cart_items = session_cart.saved_cart_items
  end

  # POST /shopping/cart_items
  def create
    session_cart.save if session_cart.new_record?
    qty = params[:cart_item][:quantity].to_i
    if cart_item = session_cart.add_variant(params[:cart_item][:variant_id], most_likely_user, qty)
      flash[:notice] = [I18n.t('out_of_stock_notice'), I18n.t('item_saved_for_later')].compact.join(' ') unless cart_item.shopping_cart_item?
      session_cart.save_user(most_likely_user)
      redirect_to(market_places_shopping_cart_items_url)
    else
      variant = Variant.includes(:product).find_by_id(params[:cart_item][:variant_id])
      if variant
        redirect_to(product_url(variant.product))
      else
        flash[:notice] = I18n.t('something_went_wrong')
        redirect_to(root_url())
      end
    end
  end

  # PUT /carts/1
  def update
    if session_cart.update_attributes(allowed_params)
      if params[:commit] && params[:commit] == "checkout"
        redirect_to( checkout_market_places_shopping_order_url('checkout', {contractor: current_contractor.slug}))
      else
        redirect_to(checkout_market_places_shopping_order_url({contractor: current_contractor.slug}), :notice => I18n.t('item_passed_update') )
      end
    else
      redirect_to(checkout_market_places_shopping_order_url({contractor: current_contractor.slug}), :notice => I18n.t('item_failed_update') )
    end
  end
## TODO
  ## This method moves saved_cart_items to your shopping_cart_items or saved_cart_items
  #   this method is called using AJAX and returns json. with the object moved,
  #   otherwise false is returned if there is an error
  #   method => PUT
  def move_to
    @cart_item = session_cart.cart_items.find(params[:id])
    if @cart_item.update_attributes(:item_type_id => params[:item_type_id])
      redirect_to(market_places_shopping_cart_items_url(contractor_context) )
    else
      redirect_to(market_places_shopping_cart_items_url(contractor_context), :notice => I18n.t('item_failed_update') )
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.xml
  def destroy
    session_cart.remove_variant(params[:variant_id]) if params[:variant_id]
    redirect_to(market_places_shopping_cart_items_url(contractor_context))
  end

  private
  def allowed_params
    params.require(:cart).permit!
  end

end
