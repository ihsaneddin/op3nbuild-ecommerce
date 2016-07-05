class Admin::SessionsController < ApplicationController

  before_action :signed_in?, only: [:create, :new]
  before_action :super_admin?, only: [:create, :destroy]
  after_action :logging_in!, only: :create

  def new
    @user_session = UserSession.new
    @user = User.new
  end

  def create
    @user_session = UserSession.new(user_params)
    if @user_session.save
      cookies[:hadean_uid] = @user_session.record.access_token
      session[:authenticated_at] = Time.now
      ## if there is a cart make sure the user_id is correct
      #set_user_to_cart_items(@user_session.record)
      #merge_carts
      flash[:notice] = I18n.t('login_successful')
      redirect_back_or_default admin_url
    else
      @user = User.new(user_params)
      redirect_to new_admin_session_url, :alert => I18n.t('login_failure')
    end
  end

  def destroy
    destroy_session
    redirect_to admin_login_url, :notice => I18n.t('logout_successful')
  end

  private

  def user_params
    params.require(:user_session).permit(:password, :email)
  end

  def signed_in?
    if current_user
      flash[:notice] = I18n.t('already_signed_in')
      redirect_back_or_default user_root_url(current_user)
    end
  end

  def super_admin?
    user = User.find_by_email user_params[:email]
    redirect_to new_admin_session_url, :alert => I18n.t('login_failure') if user.nil? || !user.super_admin?
  end

end
