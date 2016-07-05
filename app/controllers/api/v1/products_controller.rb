class Api::V1::ProductsController < API::BaseController
  
  skip_before_action :is_openbuild_user?

  include ::Openbuild::OpenbuildInitInstance 

  def index
    @products = Product.with_contractor_slug(params[:contractor])
    @products = @products.active.standard_search(params[:standard_search]).includes(:contractor, :brand, :product_type)
    respond_to do |f|
    	f.json
    end
  end

end