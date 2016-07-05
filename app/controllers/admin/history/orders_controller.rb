class Admin::History::OrdersController < Admin::BaseController
  
  load_and_authorize_resource

  # GET /admin/history/orders
  def index
    @orders = Order.accessible_by(current_ability).find_finished_order_grid(params).paginate(:page => pagination_page, :per_page => pagination_rows)
  end

  # GET /admin/history/orders/1
  def show
    @order = Order.includes([:ship_address, :invoices,
                             {:shipments => :shipping_method},
                             {:order_items => [
                                                {:variant => [:product, :variant_properties]}]
                              }]).find_by_number(params[:id])
  end

end
