class MarketPlaces::Shopping::ShippingMethodsController < MarketPlaces::Shopping::BaseController
  # GET /shopping/shipping_methods
  def index
    unless find_or_create_order.ship_address_id
      flash[:notice] = I18n.t('select_address_before_shipping_method')
      redirect_to market_places_shopping_addresses_url(contractor_context)
    else
      session_order.find_sub_total
      ##  TODO  refactor this method... it seems a bit lengthy
      @shipping_method_ids = session_order.ship_address.shipping_method_ids

      @order_items = OrderItem.includes({:variant => {:product => :shipping_category}}).order_items_in_cart(session_order.id)
      #session_order.order_
      @order_items.each do |item|
        item.variant.product.available_shipping_rates = ShippingRate.with_these_shipping_methods(item.variant.product.shipping_category.shipping_rate_ids, @shipping_method_ids)
      end
    end
  end

  # PUT /shopping/shipping_methods/1
  def update
    all_selected = true
    redirect_to(market_places_shopping_orders_url(contractor_context)) and return unless params[:shipping_category].present?
    params[:shipping_category].each_pair do |category_id, rate_id|#[rate]
      if rate_id
        items = OrderItem.includes([{:variant => :product}]).
                          where(['order_items.order_id = ? AND
                                  products.shipping_category_id = ?', session_order_id, category_id]).references(:products)

        OrderItem.where(id: items.map{|i| i.id}).update_all("shipping_rate_id = #{rate_id}")
      else
        all_selected = false
      end
    end
    if all_selected
      redirect_to(market_places_shopping_orders_url(contractor_context), :notice => I18n.t('shipping_method_updated'))
    else
      redirect_to( market_places_shopping_shipping_methods_url(contractor_context), :notice => I18n.t('all_shipping_methods_must_be_selected'))
    end
  end

end
