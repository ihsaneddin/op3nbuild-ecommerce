class Api::V1::SessionsController < API::BaseController

  before_action :activate_authlogic
  before_action :user

  def create
    @user_session = UserSession.new(@user, true)
    if @user_session.save
      cookies[:hadean_uid] = @user_session.record.access_token
      session[:authenticated_at] = Time.now
      set_user_to_cart_items(@user_session.record)
      merge_carts
      url = root_url
      if @user_session.record.admin?
        url = admin_users_url
      end
      render json: {notice: 'Login successful', url: url}.to_json, status: 201
    else
      render :json => {error: "Invalid login"}.to_json, status: 401
    end
  end

  def destroy
    current_user_session.destroy
    reset_session
    cookies.delete(:hadean_uid)
    render json: {message: 'You are signed out.'}.to_json, status: :ok
  end

  private

    def activate_authlogic
      Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::RailsAdapter.new(self)
    end

    def user_params
      params.require(:user).permit(:access_token, :authentication_token)
    end

end