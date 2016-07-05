class MarketPlaces::UnsubscribesController < MarketPlaces::BaseController
  def show
    UsersNewsletter.unsubscribe(params[:email], params[:key])
  end
end
