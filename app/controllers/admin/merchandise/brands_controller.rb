class Admin::Merchandise::BrandsController < Admin::BaseController
  def index
    @brands = Brand.all
  end

  def show
    @brand = Brand.find(params[:id])
  end

  def new
    @brand = Brand.new
  end

  def create
    @brand = Brand.new(allowed_params)
    if @brand.save
      respond_to do |f|
        f.html { 
                  flash[:notice] = "Successfully created brand."
                  redirect_to admin_merchandise_brand_url(@brand)
                }
        f.json { render json: @brand.to_json, status: 200}
      end
    else
      respond_to do |f|
        f.html { render :action => 'new' }
        f.json { render json: @brand.errors.to_json, status: 422}
      end
    end
  end

  def edit
    @brand = Brand.find(params[:id])
  end

  def update
    @brand = Brand.find(params[:id])
    if @brand.update_attributes(allowed_params)
      flash[:notice] = "Successfully updated brand."
      redirect_to admin_merchandise_brand_url(@brand)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @brand = Brand.find(params[:id])

    if @brand.products.empty?
      @brand.destroy
    else
      flash[:alert] = "Sorry this brand is already associated with a product.  You can not delete this brand."
    end

    redirect_to admin_merchandise_brands_url
  end

  private

  def allowed_params
    params.require(:brand).permit(:name)
  end

end
