class Admin::Merchandise::Changes::PropertiesController < Admin::BaseController
  helper_method :all_properties
  before_filter :get_product
  before_filter :properties

  def edit
    #@product.product_properties.build
  end

  def update
    if @product.update_attributes(allowed_params)
      flash[:notice] = "Successfully updated properties."
      redirect_to admin_merchandise_product_url(@product.id)
    else
      render :action => 'edit'
    end
  end

  private

  def allowed_params
    params.require(:product).permit!
  end

  def all_properties
     @all_properties ||= Property.all.map{|p| [ p.identifing_name, p.id ]}
  end

  def get_product
    @product = Product.find_by(id: params[:product_id])
  end

  def properties
    @prototypes = Prototype.all.map{|pt| [pt.name, pt.id]}
    @all_properties ||= []
    @units_properties ||= {}
    Property.all.each do |p|
      @all_properties << [ p.display_name, p.id ]
      @units_properties["#{p.id}"] = p.units_array 
    end
  end

end
