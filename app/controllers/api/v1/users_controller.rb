class Api::V1::UsersController < API::BaseController

  before_action :user

  def update
    if @user.update user_params
      render json: {:email => @user.email, first_name: @user.first_name, last_name: @user.last_name, permalink: @user.slug}, status: 200
    else
      render json: @user.errors.to_json, status: 422
    end
  end

  def activate
    @user.activate! if @user.may_activate?
    render json: {user: { status: @user.state} }.to_json, status: 200
  end

  def deactivate
    @user.deactivate! if @user.may_deactivate?
    if current_user
      current_user_session.destroy
      reset_session
      cookies.delete(:hadean_uid)
    end
    render json: {user: { status: @user.state} }.to_json, status: 200
  end

  def upgrade
    if @user.upgrade
      render json: {user: { status: 'upgraded!' }}.to_json, status: 200
    else
      render json: {error: "An error has ocurred"}.to_json, status: 422
    end
  end

  def downgrade
    if @user.downgrade
      render json: {user: {status: 'downgraded!'}}.to_json, status: 200
    else
      render json: {error: "An error has ocurred"}.to_json, status: 422
    end
  end

  def remove_trial
    if @user.remove_trial
      render json: {user: {status: 'trial removed!'}}.to_json, status: 200
    else
      render json: {error: "An error has ocurred"}.to_json, status: 422
    end
  end

  def cancel_trial
    if @user.cancel_trial
      render json: {user: {status: 'trial cancelled!'}}.to_json, status: 200
    else
      render json: {error: "An error has ocurred"}.to_json, status: 422
    end
  end

  def activate_account
    if @user.activate_account
      render json: {user: {status: 'account activated!'}}.to_json, status: 200
    else
      render json: {error: "An error has ocurred"}.to_json, status: 422
    end
  end

  def deactivate_account
    if @user.deactivate_account
      render json: {user: {status: 'account deactivated!'}}.to_json, status: 200
    else
      render json: {error: "An error has ocurred"}.to_json, status: 422
    end
  end

  protected
    def user_params
      params.require(:user).permit(:first_name, :last_name, :company_name)
    end

end
