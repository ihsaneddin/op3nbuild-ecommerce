class Shopping::CartItemsController < Shopping::BaseController

  before_action :cart, only: [:create, :update]

  # GET /shopping/cart_items
  def index

  end

  # POST /shopping/cart_items
  def create
    @cart.save if @cart.new_record?
    qty = params[:cart_item][:quantity].to_i
    if cart_item = @cart.add_variant(params[:cart_item][:variant_id], most_likely_user, qty)
      flash[:notice] = [I18n.t('out_of_stock_notice'), I18n.t('item_saved_for_later')].compact.join(' ') unless cart_item.shopping_cart_item?
      @cart.save_user(most_likely_user)
      redirect_to(shopping_cart_items_url)
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
    if @cart.update_attributes(allowed_params)
      if params[:commit] && params[:commit] == "checkout"
        redirect_to( checkout_shopping_order_url('checkout'))
      else
        redirect_to(shopping_cart_items_url(), :notice => I18n.t('item_passed_update') )
      end
    else
      redirect_to(shopping_cart_items_url(), :notice => I18n.t('item_failed_update') )
    end
  end
## TODO
  ## This method moves saved_cart_items to your shopping_cart_items or saved_cart_items
  #   this method is called using AJAX and returns json. with the object moved,
  #   otherwise false is returned if there is an error
  #   method => PUT
  def move_to
    @cart_item = @cart.cart_items.find(params[:id])
    if @cart_item.update_attributes(:item_type_id => params[:item_type_id])
      redirect_to(shopping_cart_items_url() )
    else
      redirect_to(shopping_cart_items_url(), :notice => I18n.t('item_failed_update') )
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.xml
  def destroy
    @cart.remove_variant(params[:variant_id]) if params[:variant_id]
    redirect_to(shopping_cart_items_url)
  end

  private
  def allowed_params
    params.require(:cart).permit!
  end

  def cart
    @cart = Cart.find(params[:id])
  end

end
