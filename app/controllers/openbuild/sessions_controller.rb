class Openbuild::SessionsController < ApplicationController
  include ::Openbuild::OpenbuildUser

  skip_before_action :verify_authenticity_token

  before_action :is_openbuild_user?
  before_action :activate_authlogic
  before_action :signed_in?
  before_action :user
  after_action :logging_in!, only: :create

  def create
    @user_session = UserSession.new(@user, true)
    if @user_session.save
      cookies[:hadean_uid] = @user_session.record.access_token
      session[:authenticated_at] = Time.now
      set_user_to_cart_items(@user_session.record)
      merge_carts
      flash[:notice] = I18n.t('login_successful')
      redirect_to after_sign_in_url
    else
      redirect_to login_url, :alert => I18n.t('login_failure')
    end
  end

  def destroy
    @user.force_logged_out!
    render json: {message: 'You have signed out.'}.to_json, status: :ok
    #respond_to do |f|
    #  f.html {
    #    destroy_session
    #    redirect_to login_url, :notice => I18n.t('logout_successful')}
    #  f.json {
    #    @user.force_logged_out!
    #    render json: {message: 'You have signed out.'}.to_json, status: :ok}
    #end
  end

  private

    def after_sign_in_url
      return path if path.present?
      user_root_url(@user)
    end

    def user
      @user = User.find_by_access_token @openbuild_user.access_token
    end

    def activate_authlogic
      Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::RailsAdapter.new(self)
    end

    def signed_in?
      if current_user
        if current_user.access_token.eql? @openbuild_user.access_token
          path.present?? redirect_to(path) : redirect_to(user_root_url(current_user))
        else  
          current_user_session.destroy
          reset_session
          cookies.delete(:hadean_uid)
        end
      end
    end

    def path
      begin
        path = is_path_present?? eval(params[:path]) : params[:path]
        return path
      rescue
        nil
      end
    end

    def is_path_present?
      params[:path].present? && params[:path_eval].nil?
    end
end
