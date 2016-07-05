class Admin::Wizards::Products::ItemsController < Admin::Wizards::BaseController

	before_action :product_types
	before_action :brands
	before_action :shipping_categories
	before_action :properties
	before_action :image_groups

	def new
		@product = Product.new
		@product.images.build
		@product.variants.build
		@product.product_properties.build
	end

	def create
		@product = Product.new product_params
		@product.contractor = current_user
		if @product.save
			@product.deleted_at = nil
      @product.save
			redirect_to admin_merchandise_product_url(@product, activate: true), notice: "Successcully create product."
		else
			render :new
		end
	end

	def edit
		@product = Product.includes(:images, :variants, :product_properties).find params[:id]
	end

	def update
		@product = Product.find params[:id]
		if @product.update product_params
			redirect_to admin_merchandise_product_url(@product), notice: "Successcully update product."
		else
			render :edit
		end
	end

	private

		def product_params
			params.require(:product).permit(:name, :description, :product_keywords, :set_keywords, :product_type_id,
                                      :prototype_id, :shipping_category_id, :permalink, :available_at, :deleted_at,
                                      :meta_keywords, :meta_description, :featured, :description_markup, :brand_id,
                                      :variants_attributes => [:id, :sku, :name, :price, :cost, :initial_stock, :deleted_at, :master, :inventory_id, :_destroy],
                                      :images_attributes => [:id, :position, :caption, :photo, :photo_from_link, :_destroy],
                                      :product_properties_attributes => [:id, :property_id, :value, :value_unit, :description, :position, :_destroy])
		end

		def product_only_params
			
		end

		def product_types
			@select_product_types = ProductType.all.collect{|pt| [pt.name, pt.id]}
		end

		def brands
			@brands = Brand.order(:name).collect {|ts| [ts.name, ts.id]}
		end

		def shipping_categories
			@select_shipping_category = ShippingCategory.all.collect {|sc| [sc.name, sc.id]}
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

		def image_groups
			@image_groups ||= ImageGroup.where(:product_id => @product).map{|i| [i.name, i.id]}
		end

end